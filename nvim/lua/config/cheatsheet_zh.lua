-- 繁體中文翻譯：keymap 說明 & 分類名稱
-- 沒翻到的會只顯示英文；想改用詞直接改這裡
local M = {}

M.categories = {
  ["Agents (AI CLI)"] = "AI Agent",
  ["Tabs"] = "分頁",
  ["Pickers  ( ; )"] = "搜尋選單",
  ["General"] = "一般",
  ["Files"] = "檔案總管",
  ["Buffers"] = "緩衝區",
  ["Code / LSP"] = "程式碼 / LSP",
  ["Git"] = "Git",
  ["Diff / Review"] = "差異 / 審查",
  ["Search & Replace"] = "搜尋與取代",
  ["Yank & Paste"] = "複製與貼上",
  ["Toggles"] = "開關",
  ["Windows"] = "視窗",
  ["Motion & Editing"] = "移動與編輯",
  ["Diagnostics & Jumps"] = "診斷與跳轉",
  ["Other"] = "其他",
}

M.desc = {
  -- Agents
  ["Agent detach"] = "中斷 agent 連線（tmux 背景繼續跑）",
  ["Agent focus"] = "切換焦點到 agent",
  ["Agent prompt library"] = "agent 內建提示詞",
  ["Agent select / attach (all projects)"] = "選擇 / 接回 agent session（所有專案）",
  ["Agent toggle"] = "顯示 / 隱藏 agent",
  ["Claude"] = "開啟 Claude",
  ["Codex"] = "開啟 Codex",
  ["Gemini"] = "開啟 Gemini",
  ["Send file"] = "把目前檔案送給 agent",
  ["Send selection"] = "把選取內容送給 agent",
  ["Send this"] = "把游標位置送給 agent",

  -- Tabs
  ["Close other tabs"] = "關閉其他分頁",
  ["Close tab"] = "關閉分頁",
  ["Find tab"] = "搜尋分頁",
  ["Move tab left"] = "分頁往左移",
  ["Move tab right"] = "分頁往右移",
  ["New tab"] = "新分頁（命名）",
  ["New tab at directory"] = "新分頁並指定專案目錄",
  ["Next tab"] = "下一個分頁",
  ["Prev tab"] = "上一個分頁",
  ["Rename tab"] = "重新命名分頁",

  -- Pickers
  ["Buffers (all tabs)"] = "緩衝區（所有分頁）",
  ["Config files"] = "Neovim 設定檔",
  ["Diagnostics"] = "診斷訊息列表",
  ["Files"] = "找檔案",
  ["Git changed files"] = "Git 有變更的檔案",
  ["Grep"] = "全文搜尋",
  ["Grep word / selection"] = "搜尋游標下的字 / 選取內容",
  ["Help"] = "說明文件",
  ["Highlights"] = "高亮群組",
  ["Incoming calls"] = "誰呼叫了這個函式",
  ["Keymaps"] = "搜尋快捷鍵",
  ["Notifications"] = "通知紀錄",
  ["Recent files"] = "最近開過的檔案",
  ["Resume picker"] = "回到上一次的搜尋",
  ["Symbols (LSP)"] = "符號列表（LSP）",
  ["Symbols (treesitter)"] = "符號列表（treesitter）",
  ["TODOs"] = "所有 TODO",

  -- General
  ["Clear hlsearch"] = "清除搜尋高亮",
  ["Keymap cheat sheet (browser)"] = "快捷鍵速查頁（瀏覽器）",
  ["Lazy (plugins)"] = "插件管理（Lazy）",
  ["Quit all"] = "全部離開",
  ["Save file"] = "存檔",
  ["Terminal"] = "終端機",

  -- Files
  ["Explorer (cwd)"] = "檔案總管（專案根目錄）",
  ["Explorer (file dir)"] = "檔案總管（目前檔案位置）",
  ["Oil (file dir)"] = "Oil 檔案編輯（目前檔案位置）",

  -- Buffers
  ["Delete buffer"] = "關閉緩衝區",
  ["Delete other buffers"] = "關閉其他緩衝區",
  ["Next buffer"] = "下一個緩衝區",
  ["Prev buffer"] = "上一個緩衝區",

  -- Code / LSP
  ["Code action"] = "程式碼動作（快速修正）",
  ["Format"] = "格式化",
  ["Goto declaration"] = "跳到宣告",
  ["Goto definition"] = "跳到定義",
  ["Goto source definition / implementation"] = "跳到原始碼 / 實作",
  ["Goto type definition"] = "跳到型別定義",
  ["Hover"] = "顯示文件說明",
  ["LSP info"] = "LSP 狀態",
  ["Line diagnostics"] = "這一行的診斷訊息",
  ["Mason (tools)"] = "工具管理（Mason）",
  ["References"] = "找出所有引用",
  ["Rename file (update imports)"] = "重新命名檔案（同步更新 import）",
  ["Rename symbol"] = "重新命名變數 / 函式",
  ["Signature help"] = "函式參數提示",

  -- Git
  ["Blame (whole file)"] = "整個檔案的 blame",
  ["Blame window"] = "blame 視窗",
  ["Lazygit"] = "開啟 lazygit",
  ["Lazygit file history"] = "lazygit 看這個檔案的歷史",
  ["Worktrees"] = "Worktree 列表（C-n 新增 · C-d 刪除）",
  ["New worktree (+ tab + agent)"] = "新增 worktree（自動開 tab + agent）",
  ["Next hunk"] = "下一個變更區塊",
  ["Open in browser"] = "在瀏覽器開啟（GitHub）",
  ["Open lines in browser"] = "在瀏覽器開啟選取的行",
  ["Prev hunk"] = "上一個變更區塊",
  ["Preview hunk"] = "預覽變更區塊",
  ["Reset hunk"] = "還原變更區塊",
  ["Stage / unstage file"] = "stage / unstage 整個檔案",
  ["Stage / unstage hunk"] = "stage / unstage 變更區塊",

  -- Diff
  ["Diff file vs index"] = "比較檔案與 stage 版本",
  ["File history"] = "這個檔案的歷史",
  ["Repo history"] = "整個 repo 的歷史",
  ["Review changes (CodeDiff)"] = "審查所有變更（CodeDiff）",

  -- Search & Replace
  ["Next TODO"] = "下一個 TODO",
  ["Prev TODO"] = "上一個 TODO",
  ["Replace in file"] = "在目前檔案中取代",
  ["Replace word"] = "取代游標下的字",
  ["Search & replace"] = "全專案搜尋與取代",

  -- Yank & Paste
  ["Absolute path#Lline"] = "複製絕對路徑 + 行號",
  ["Copy relative path"] = "複製相對路徑",
  ["Delete char (no yank)"] = "刪除字元（不覆蓋剪貼簿）",
  ["Paste last yank"] = "貼上最後一次複製的內容",
  ["Paste last yank (before)"] = "貼上最後一次複製的內容（游標前）",
  ["Relative path"] = "複製相對路徑",
  ["Relative path#Lline"] = "複製相對路徑 + 行號",
  ["Selection as code block"] = "選取內容複製成 code block",

  -- Toggles
  ["Toggle Diagnostics"] = "開關診斷訊息",
  ["Toggle Indent Guides"] = "開關縮排線",
  ["Toggle Inlay Hints"] = "開關型別提示",
  ["Toggle Relative number"] = "開關相對行號",
  ["Toggle Spelling"] = "開關拼字檢查",
  ["Toggle Treesitter Highlight"] = "開關語法高亮",
  ["Toggle Wrap"] = "開關自動換行",
  ["Toggle Zen Mode"] = "開關專注模式",
  ["Zen mode"] = "專注模式",

  -- Windows
  ["Close other windows"] = "關閉其他視窗",
  ["Close window"] = "關閉視窗",
  ["Equalize windows"] = "視窗等寬",
  ["Narrower"] = "視窗變窄",
  ["Shorter"] = "視窗變矮",
  ["Show diagnostics under the cursor"] = "顯示游標處的診斷訊息",
  ["Split below"] = "往下分割",
  ["Split right"] = "往右分割",
  ["Taller"] = "視窗變高",
  ["Wider"] = "視窗變寬",
  ["Window down"] = "移到下方視窗",
  ["Window left"] = "移到左邊視窗",
  ["Window right"] = "移到右邊視窗",
  ["Window up"] = "移到上方視窗",

  -- Motion & Editing
  ["Add empty line above cursor"] = "上方插入空行",
  ["Add empty line below cursor"] = "下方插入空行",
  ["Add surrounding"] = "加上包圍符號",
  ["Add surrounding to selection"] = "選取內容加上包圍符號",
  ["Comment textobject"] = "註解區塊（文字物件）",
  ["Decrement"] = "數值減少 / 切換",
  ["Delete next surrounding"] = "刪除下一個包圍符號",
  ["Delete previous surrounding"] = "刪除上一個包圍符號",
  ["Delete surrounding"] = "刪除包圍符號",
  ["End of line"] = "跳到行尾",
  ["Increment"] = "數值增加 / 切換",
  ["Leap backward"] = "Leap 往回跳",
  ["Leap forward"] = "Leap 往前跳",
  ["Leap from window"] = "Leap 跳到其他視窗",
  ["Move line down"] = "整行下移",
  ["Move line up"] = "整行上移",
  ["Move lines down"] = "選取行下移",
  ["Move lines up"] = "選取行上移",
  ["Replace next surrounding"] = "替換下一個包圍符號",
  ["Replace previous surrounding"] = "替換上一個包圍符號",
  ["Replace surrounding"] = "替換包圍符號",
  ["Select child (inner) node"] = "選取內層語法節點",
  ["Select next node"] = "選取下一個語法節點",
  ["Select parent (outer) node"] = "選取外層語法節點",
  ["Select previous node"] = "選取上一個語法節點",
  ["Toggle comment"] = "切換註解",
  ["Toggle comment line"] = "切換整行註解",

  -- Diagnostics & Jumps
  ["Jump to the first diagnostic in the current buffer"] = "跳到第一個診斷",
  ["Jump to the last diagnostic in the current buffer"] = "跳到最後一個診斷",
  ["Next diagnostic"] = "下一個診斷",
  ["Next error"] = "下一個錯誤",
  ["Next reference"] = "下一個相同符號",
  ["Prev diagnostic"] = "上一個診斷",
  ["Prev error"] = "上一個錯誤",
  ["Prev reference"] = "上一個相同符號",

  -- Other
  ["Opens filepath or URI under cursor with the system handler (file explorer, web browser, …)"] = "用系統程式開啟游標下的路徑或網址",
}

-- mini.bracketed style: "<Target> <direction>"
local targets = {
  Buffer = "緩衝區", Comment = "註解區塊", Conflict = "Git 衝突標記", Diagnostic = "診斷",
  File = "檔案", Indent = "縮排變化", ["Indent change"] = "縮排變化", Jump = "跳轉紀錄",
  Location = "location list", Oldfile = "最近檔案", Quickfix = "quickfix", Treesitter = "語法節點",
  Undo = "復原狀態", Window = "視窗", Yank = "複製紀錄",
}
local dirs = { forward = "下一個", backward = "上一個", first = "第一個", last = "最後一個" }

function M.get(desc)
  desc = vim.trim(desc)
  if M.desc[desc] then return M.desc[desc] end
  local n = desc:match("^Tab (%d)$")
  if n then return "跳到第 " .. n .. " 個分頁" end
  local target, dir = desc:match("^(.-) (%a+)$")
  if target and dirs[dir] and targets[target] then
    local t = targets[target]
    return dirs[dir] .. (t:match("^%a") and " " or "") .. t
  end
  return nil
end

return M
