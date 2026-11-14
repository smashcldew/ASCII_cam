"""
即時 ASCII 視訊鏡頭
攝影機 → 逐格轉 ASCII → 預覽視窗 / 虛擬攝影機（給 Discord、Meet、OBS 用）

安裝：
    pip install opencv-python numpy pyvirtualcam
    虛擬攝影機需要先安裝 OBS Studio（用它內建的 OBS Virtual Camera 驅動）

用法：
    python ascii_cam.py                 只開預覽視窗
    python ascii_cam.py --vcam          同時輸出到虛擬攝影機
    python ascii_cam.py --color         彩色字元
    python ascii_cam.py --cam 1         換成第 2 支攝影機
預覽視窗中按 q 離開，按 c 切換彩色，按 i 反轉明暗
"""
import argparse
import cv2
import numpy as np

CHARS = " .:-=+*#%@"   # 由暗到亮（黑底畫面：越亮的地方用越密的字元）
CELL_W, CELL_H = 8, 12  # 每個字元格子的像素大小
OUT_W, OUT_H = 1280, 720


def build_glyphs(chars):
    """先把每個字元畫成一小格 (CELL_H x CELL_W) 的遮罩，之後直接查表拼起來，速度才夠快"""
    glyphs = np.zeros((len(chars), CELL_H, CELL_W), dtype=np.float32)
    for i, ch in enumerate(chars):
        tile = np.zeros((CELL_H, CELL_W), dtype=np.uint8)
        cv2.putText(tile, ch, (0, CELL_H - 3), cv2.FONT_HERSHEY_PLAIN, 0.75, 255, 1, cv2.LINE_AA)
        glyphs[i] = tile / 255.0
    return glyphs


def frame_to_ascii_image(frame, glyphs, color=False, invert=False):
    cols, rows = OUT_W // CELL_W, OUT_H // CELL_H
    small = cv2.resize(frame, (cols, rows), interpolation=cv2.INTER_AREA)
    gray = cv2.cvtColor(small, cv2.COLOR_BGR2GRAY).astype(np.float32)
    if invert:
        gray = 255 - gray

    # 每一格的亮度 → 字元編號
    idx = (gray / 255 * (len(glyphs) - 1)).round().astype(np.int32)

    # 查表拼圖：(rows, cols, H, W) → (rows*H, cols*W)
    tiles = glyphs[idx]
    mask = tiles.transpose(0, 2, 1, 3).reshape(rows * CELL_H, cols * CELL_W)

    if color:
        # 每格用原圖顏色上色
        col = np.repeat(np.repeat(small.astype(np.float32), CELL_H, axis=0), CELL_W, axis=1)
        out = col * mask[..., None]
    else:
        out = np.repeat(mask[..., None] * 255, 3, axis=2)
    return out.clip(0, 255).astype(np.uint8)


def main():
    parser = argparse.ArgumentParser(description="即時 ASCII 視訊鏡頭")
    parser.add_argument("--cam", type=int, default=0, help="攝影機編號")
    parser.add_argument("--vcam", action="store_true", help="輸出到虛擬攝影機（需安裝 OBS）")
    parser.add_argument("--color", action="store_true", help="彩色字元")
    parser.add_argument("--invert", action="store_true", help="反轉明暗")
    parser.add_argument("--no-preview", action="store_true", help="不開預覽視窗")
    args = parser.parse_args()

    cap = cv2.VideoCapture(args.cam, cv2.CAP_DSHOW)  # Windows 用 DSHOW 開啟較快
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, OUT_W)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, OUT_H)
    if not cap.isOpened():
        print("打不開攝影機，試試 --cam 1")
        return

    glyphs = build_glyphs(CHARS)
    color, invert = args.color, args.invert

    vcam = None
    if args.vcam:
        import pyvirtualcam
        vcam = pyvirtualcam.Camera(width=OUT_W, height=OUT_H, fps=30, fmt=pyvirtualcam.PixelFormat.BGR)
        print(f"虛擬攝影機已啟動：{vcam.device}（在視訊軟體裡選它當鏡頭）")

    try:
        while True:
            ok, frame = cap.read()
            if not ok:
                print("讀不到畫面")
                break
            frame = cv2.flip(frame, 1)  # 鏡像，跟照鏡子一樣
            frame = cv2.resize(frame, (OUT_W, OUT_H))
            out = frame_to_ascii_image(frame, glyphs, color, invert)

            if vcam:
                vcam.send(out)
                vcam.sleep_until_next_frame()

            if not args.no_preview:
                cv2.imshow("ASCII Cam (q 離開 / c 彩色 / i 反轉)", out)
                key = cv2.waitKey(1) & 0xFF
                if key == ord("q"):
                    break
                elif key == ord("c"):
                    color = not color
                elif key == ord("i"):
                    invert = not invert
    finally:
        cap.release()
        if vcam:
            vcam.close()
        cv2.destroyAllWindows()


if __name__ == "__main__":
    main()
