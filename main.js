const { app, BrowserWindow, Menu, globalShortcut } = require('electron');
const fs = require('fs');
const path = require('path');
const os = require('os');

let mainWindow = null;

function getToken() {
  try {
    const homeDir = os.homedir();
    const configPath = path.join(homeDir, '.openclaw', 'openclaw.json');
    const content = fs.readFileSync(configPath, 'utf8');
    const config = JSON.parse(content);
    const token = config?.gateway?.auth?.token;
    if (token && typeof token === 'string' && token.length > 0) {
      return token;
    }
    return null;
  } catch (e) {
    return null;
  }
}

function getDashboardURL() {
  const token = getToken();
  const base = 'http://127.0.0.1:18789';
  if (token) {
    return `${base}/#token=${token}`;
  }
  return base;
}

function createWindow() {
  const dashboardURL = getDashboardURL();

  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 900,
    minHeight: 600,
    title: 'OpenClaw Gateway Dashboard',
    backgroundColor: '#1e1e1e',
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      webSecurity: true,
      allowRunningInsecureContent: true,
      spellcheck: false
    },
    show: false
  });

  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
    mainWindow.focus();
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  // Register global shortcuts that won't conflict with web content
  const template = [
    {
      label: 'OpenClaw',
      submenu: [
        { label: '关于', role: 'about' },
        { type: 'separator' },
        { label: '重新加载', accelerator: 'CmdOrCtrl+R', click: () => mainWindow.reload() },
        { label: '强制刷新', accelerator: 'CmdOrCtrl+Shift+R', click: () => mainWindow.webContents.reloadIgnoringCache() },
        { type: 'separator' },
        { label: '开发者工具', accelerator: 'Alt+Cmd+I', click: () => mainWindow.webContents.toggleDevTools() },
        { type: 'separator' },
        { label: '退出', accelerator: 'Cmd+Q', click: () => app.quit() }
      ]
    },
    {
      label: '编辑',
      submenu: [
        { label: '撤销', accelerator: 'Cmd+Z', role: 'undo' },
        { label: '重做', accelerator: 'Shift+Cmd+Z', role: 'redo' },
        { type: 'separator' },
        { label: '剪切', accelerator: 'Cmd+X', role: 'cut' },
        { label: '复制', accelerator: 'Cmd+C', role: 'copy' },
        { label: '粘贴', accelerator: 'Cmd+V', role: 'paste' },
        { label: '全选', accelerator: 'Cmd+A', role: 'selectAll' },
        { type: 'separator' },
        { label: '查找', accelerator: 'Cmd+F', role: 'find' }
      ]
    },
    {
      label: '视图',
      submenu: [
        { label: '全屏', accelerator: 'Ctrl+Cmd+F', click: () => {
          mainWindow.setFullScreen(!mainWindow.isFullScreen());
        }},
        { label: '放大', accelerator: 'Cmd+Plus', click: () => {
          const z = mainWindow.webContents.getZoomFactor();
          mainWindow.webContents.setZoomFactor(Math.min(z + 0.1, 3));
        }},
        { label: '缩小', accelerator: 'Cmd+-', click: () => {
          const z = mainWindow.webContents.getZoomFactor();
          mainWindow.webContents.setZoomFactor(Math.max(z - 0.1, 0.3));
        }},
        { label: '重置缩放', accelerator: 'Cmd+0', click: () => {
          mainWindow.webContents.setZoomFactor(1);
        }},
        { type: 'separator' },
        { label: '实际大小', role: 'resetZoom' },
        { label: '放大', role: 'zoomIn' },
        { label: '缩小', role: 'zoomOut' }
      ]
    },
    {
      label: '窗口',
      submenu: [
        { label: '最小化', accelerator: 'Cmd+M', role: 'minimize' },
        { label: '关闭', accelerator: 'Cmd+W', role: 'close' }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);

  mainWindow.loadURL(dashboardURL);
}

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('will-quit', () => {
  globalShortcut.unregisterAll();
});
