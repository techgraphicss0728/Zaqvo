import './index.css'
import Navbar from './components/Navbar'
import Hero from './components/Hero'
import Features from './components/Features'
import About from './components/About'
import Services from './components/Services'
import WhyChooseUs from './components/WhyChooseUs'
import Products from './components/Products'
import Testimonials from './components/Testimonials'
import Team from './components/Team'
import CTABanner from './components/CTABanner'
// Sections removed by user: Blog, ContactCTABar
import Footer from './components/Footer'

import Terms from './components/terms'
import PrivacyPolicy from './components/PrivacyPolicy'

import { BrowserRouter, Routes, Route } from 'react-router-dom'

// function App() {
//   return (
//     <div className="min-h-screen">
//       <Navbar />
//       <main>
//         <Hero />
//         <Features />
//         <About />
//         <Services />
//         <WhyChooseUs />
//         <Products />
//         <Testimonials />
//         <Team />
//         <CTABanner />
//       </main>
//       <Footer />
//     </div>
//   )
// }

// export default App



function HomePage() {
  return (
    <>
      <Hero />
      <Features />
      <About />
      <Services />
      <WhyChooseUs />
      <Products />
      <Testimonials />
      <Team />
      <CTABanner />
    </>
  )
}

function App() {
  return (
    <BrowserRouter>
      <div className="min-h-screen">
        <Navbar />
        <main>
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/terms" element={<Terms />} />
            <Route path="/privacy" element={<PrivacyPolicy />} />
          </Routes>
        </main>
        <Footer />
      </div>
    </BrowserRouter>
  )
}

export default App