import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { Toaster } from 'sonner'
import App from './App'
import './index.css'
import faviconZaqvo from './assets/FEVICON_ZAQVO.png'

const link =
  document.querySelector<HTMLLinkElement>("link[rel~='icon']") ?? document.createElement('link')
link.rel = 'icon'
link.type = 'image/png'
link.href = faviconZaqvo
if (!link.parentElement) document.head.appendChild(link)

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
      <Toaster richColors closeButton position="top-right" />
    </BrowserRouter>
  </React.StrictMode>
)
