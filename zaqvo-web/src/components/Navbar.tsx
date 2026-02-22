import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import logoImg from '@/assets/LOGO_ZAQVO.png'
import { Button } from '@/components/ui/button'

// navLinks removed by user for extreme simplification
const PHONE_NUMBER = '+917661002155'

export default function Navbar() {
    const [scrolled, setScrolled] = useState(false)

    useEffect(() => {
        const handleScroll = () => setScrolled(window.scrollY > 20)
        window.addEventListener('scroll', handleScroll)
        return () => window.removeEventListener('scroll', handleScroll)
    }, [])

    return (
        <nav
            className={`fixed top-0 left-0 right-0 z-50 bg-white transition-shadow duration-300 ${scrolled ? 'shadow-md shadow-gray-200' : 'shadow-sm'}`}
        >
            <div className="max-w-7xl mx-auto px-4 md:px-8 flex items-center justify-between h-16">
                {/* Logo - navigates to home page */}
                <Link to="/" className="flex items-center">
                    <img src={logoImg} alt="Zaqvo" className="h-10 w-auto object-contain" />
                </Link>

                {/* Desktop Nav Links */}
                {/* Desktop Nav Links removed per user simplification */}

                {/* CTA Button - same on desktop and mobile; <a> as child so tel: link works */}
                <div>
                    <Button asChild className="bg-primary hover:bg-primary/90 text-white font-semibold px-5 py-2 rounded-md text-sm">
                        <a href={`tel:${PHONE_NUMBER}`}>Book a Call</a>
                    </Button>
                </div>
            </div>
        </nav>
    )
}
