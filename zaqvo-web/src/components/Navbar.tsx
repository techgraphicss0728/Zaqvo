import { useState, useEffect } from 'react'
import logoImg from '@/assets/LOGO_ZAQVO.png'
import { Menu } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet'

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
                {/* Logo */}
                <a href="#home" className="flex items-center">
                    <img src={logoImg} alt="Zaqvo" className="h-10 w-auto object-contain" />
                </a>

                {/* Desktop Nav Links */}
                {/* Desktop Nav Links removed per user simplification */}

                {/* CTA Button */}
                <div className="hidden md:block">
                    <a href={`tel:${PHONE_NUMBER}`}>
                        <Button className="bg-primary hover:bg-primary/90 text-white font-semibold px-5 py-2 rounded-md text-sm">
                            Book a Call
                        </Button>
                    </a>
                </div>

                {/* Mobile Hamburger */}
                <div className="md:hidden">
                    <Sheet>
                        <SheetTrigger asChild>
                            <button className="text-dark p-2 rounded-md hover:bg-gray-100 transition-colors" aria-label="Open menu">
                                <Menu className="h-6 w-6" />
                            </button>
                        </SheetTrigger>
                        <SheetContent side="right" className="w-72 bg-white">
                            <div className="flex flex-col h-full pt-8">
                                <a href="#home" className="flex items-center mb-8">
                                    <img src={logoImg} alt="Zaqvo" className="h-10 w-auto object-contain" />
                                </a>
                                {/* Mobile Links removed per user simplification */}
                                <div className="mt-8">
                                    <a href={`tel:${PHONE_NUMBER}`}>
                                        <Button className="w-full bg-primary hover:bg-primary/90 text-white font-semibold">
                                            Book a Call
                                        </Button>
                                    </a>
                                </div>
                            </div>
                        </SheetContent>
                    </Sheet>
                </div>
            </div>
        </nav>
    )
}
