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

## 快速開始（Windows，推薦）

不用自己處理 Python 或 pip，也不用設定 PATH：

1. 下載或複製整個 `ASCII_cam` 資料夾（需要能連網）。
2. 點兩下 **`install.bat`**，它會自動完成：
   - 尋找 Python；找不到就用 winget 安裝 Python 3.12（裝完請關掉視窗，再點一次 `install.bat`）。
   - 在資料夾內建立專用環境 `.venv`，不會影響電腦上其他的 Python。
   - 安裝 `requirements.txt` 裡的套件。
   - 檢查有沒有 OBS Studio；沒有的話會詢問要不要自動安裝（只用預覽視窗可以跳過）。
3. 點兩下 **`run.bat`**，從選單挑模式：預覽、預覽加虛擬攝影機、預覽加虛擬攝影機加彩色。
4. 在 Discord、Meet 等軟體的鏡頭設定選 **OBS Virtual Camera**。

`run.bat` 也可以直接帶參數，例如：

```bat
run.bat --vcam --color --cam 1
```

### 常見問題

- **套件安裝失敗、說找不到符合的版本**：多半是 Python 太新，opencv 或 pyvirtualcam 還沒有對應的安裝包。請改裝 Python 3.12，刪除資料夾裡的 `.venv`，再重新執行 `install.bat`。
- **雙擊後視窗一閃而過**：請改成在資料夾空白處按右鍵開啟終端機，再輸入 `install.bat`，就能看到完整的錯誤訊息。
- **沒有 winget**：請手動到 [python.org](https://www.python.org/downloads/) 安裝 Python，安裝時務必勾選 `Add python.exe to PATH`。
- **想更新程式**：把新版 `ascii_cam.py` 覆蓋過去即可；若 `requirements.txt` 有變動，再執行一次 `install.bat`。

## 手動安裝

已經熟悉 Python 的話，也可以自己裝：

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
