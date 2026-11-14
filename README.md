# ASCII_cam
turn your camera stream to ASCII image

即時把攝影機畫面轉成 ASCII 字元畫，可以在預覽視窗看，也能輸出成**虛擬攝影機**，直接在 Discord、Google Meet、OBS 等視訊軟體裡使用。

## 原理

```
攝影機 → 縮小並轉灰階 → 亮度對應字元 → 把字元畫回成影像 → 預覽 / 虛擬攝影機
```

1. 每一格畫面縮小成 `欄數 × 列數`，每個像素代表一個字元格子。
2. 轉成灰階，用亮度從 ` .:-=+*#%@` 裡挑字元（越亮字越密）。
3. 每個字元事先畫成小圖塊（glyph），用 NumPy 查表一次拼出整張圖，1280×720 每格約 10 ms。
4. 彩色模式下，灰階只負責「選哪個字」，顏色則取自縮小後的原圖，把顏色補回字元上。

## 安裝

```bash
pip install -r requirements.txt
```

要使用虛擬攝影機，需要先安裝 [OBS Studio](https://obsproject.com/)（`pyvirtualcam` 透過它內建的 OBS Virtual Camera 驅動輸出，OBS 本身不用開）。

## 使用

```bash
python ascii_cam.py                 # 只開預覽視窗
python ascii_cam.py --vcam          # 同時輸出到虛擬攝影機
python ascii_cam.py --vcam --color  # 彩色字元
python ascii_cam.py --cam 1         # 改用第 2 支攝影機
```

| 參數 | 說明 |
| --- | --- |
| `--cam N` | 攝影機編號，預設 0 |
| `--vcam` | 輸出到虛擬攝影機 |
| `--color` | 彩色字元 |
| `--invert` | 反轉明暗 |
| `--no-preview` | 不開預覽視窗 |

預覽視窗快捷鍵：`q` 離開、`c` 切換彩色、`i` 反轉明暗。

在視訊軟體的鏡頭設定中選 **OBS Virtual Camera** 即可看到 ASCII 畫面。

## 調整

- 字元大小：修改 `CELL_W, CELL_H`（預設 `8, 12`），改小字更細、畫面更清楚。
- 字元集：修改 `CHARS`，由暗到亮排列。
- 輸出解析度：修改 `OUT_W, OUT_H`（預設 1280×720）。

## 注意事項

- 實體攝影機同一時間只能被一個程式使用，視訊軟體要選虛擬攝影機，不能選原本的鏡頭。
- 打不開攝影機時，試試 `--cam 1`。
