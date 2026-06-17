import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App'
import './index.css'
import faviconZaqvo from './assets/FEVICON_ZAQVO.png'
import { ToastProvider } from '@/hooks/useToast'

const link =
  document.querySelector<HTMLLinkElement>("link[rel~='icon']") ?? document.createElement('link')
link.rel = 'icon'
link.type = 'image/png'
link.href = faviconZaqvo
if (!link.parentElement) document.head.appendChild(link)

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <ToastProvider>
        <App />
      </ToastProvider>
    </BrowserRouter>
  </React.StrictMode>
)
