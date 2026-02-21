import { useEffect, useRef, useState } from 'react'
import { Carousel, CarouselContent, CarouselItem, type CarouselApi } from '@/components/ui/carousel'
import Autoplay from 'embla-carousel-autoplay'

import banner1 from '../assets/banner_1.jpg.jpeg'
import banner2 from '../assets/banner_2.jpg.jpeg'

const slides = [
    {
        image: banner1,
        // Mobile focal point: center the water bottle (right side of image)
        mobilePosition: 'object-[70%_center]',
        desktopPosition: 'object-center',
        heading: 'PURE WATER. PURE LIFE.',
        subheading: 'Experience crystal-clear hydration with ZAQVO — safe, mineral-rich, and perfectly purified for your family\'s healthy lifestyle.',
    },
    {
        image: banner2,
        // Mobile focal point: center the delivery man (right side of image)
        mobilePosition: 'object-[65%_center]',
        desktopPosition: 'object-center',
        heading: 'The Smart Choice for Pure Water',
        subheading: 'Give your family the purity they deserve with our advanced water filtration system — safe, mineral-rich, and 100% trustworthy.',
    },
]

export default function Hero() {
    const [api, setApi] = useState<CarouselApi>()
    const [current, setCurrent] = useState(0)
    const plugin = useRef(Autoplay({ delay: 5000, stopOnInteraction: false }))

    useEffect(() => {
        if (!api) return
        api.on('select', () => setCurrent(api.selectedScrollSnap()))
    }, [api])

    return (
        <section id="home" className="relative overflow-hidden">
            {/* Decorative circles — hidden on mobile to reduce clutter */}
            <div className="hidden md:block absolute top-20 right-10 w-64 h-64 rounded-full border border-primary/20 opacity-30 z-10 pointer-events-none" />
            <div className="hidden md:block absolute top-40 right-24 w-40 h-40 rounded-full border border-primary/30 opacity-20 z-10 pointer-events-none" />
            <div className="hidden md:block absolute -top-10 -left-10 w-80 h-80 rounded-full bg-primary/5 z-10 pointer-events-none" />

            <Carousel
                setApi={setApi}
                plugins={[plugin.current]}
                opts={{ loop: true }}
                className="w-full"
            >
                <CarouselContent className="-ml-0">
                    {slides.map((slide, index) => (
                        <CarouselItem key={index} className="pl-0 relative">

                            {/*
                             * RESPONSIVE STRATEGY:
                             * Mobile  → 85vw tall, image focused on subject via object-position,
                             *           text overlay sits at the bottom with a strong gradient
                             * Desktop → 90vh tall, image shows fully, text sits in the
                             *           left column just like the original banner design
                             */}

                            {/* ── Mobile layout (hidden on md+) ── */}
                            <div className="block md:hidden relative w-full" style={{ height: '85vw', minHeight: '320px', maxHeight: '520px' }}>
                                <img
                                    src={slide.image}
                                    // alt={slide.heading}
                                    className={`absolute inset-0 w-full h-full object-cover ${slide.mobilePosition}`}
                                />
                                {/* Strong bottom-up gradient so text is always readable */}
                                <div className="absolute inset-0 bg-gradient-to-t from-[#0d2db4]/95 via-[#0d2db4]/60 to-[#0d2db4]/10" />

                                {/* Text pinned to bottom */}
                                <div className="absolute bottom-0 left-0 right-0 px-5 pb-6 pt-10 text-white">
                                    <h1 className="text-xl font-extrabold leading-tight mb-2 drop-shadow">
                                        {slide.heading}
                                    </h1>
                                    {/* <p className="text-sm leading-relaxed text-white/90">
                                        {slide.subheading}
                                    </p> */}
                                </div>
                            </div>

                            {/* ── Desktop layout (hidden on mobile) ── */}
                            <div className="hidden md:block relative w-full" style={{ height: 'clamp(400px, 46vw, 889px)' }}>
                                <img
                                    src={slide.image}
                                    alt={slide.heading}
                                    className={`absolute inset-0 w-full h-full object-cover ${slide.desktopPosition}`}
                                />
                                {/* Subtle left-side gradient to boost text legibility without covering the artwork */}
                                <div className="absolute inset-0 bg-gradient-to-r from-[#0d2db4]/70 via-[#0d2db4]/20 to-transparent" />
                            </div>

                        </CarouselItem>
                    ))}
                </CarouselContent>

                {/* Slide Indicators */}
                <div className="absolute bottom-4 md:bottom-8 left-1/2 -translate-x-1/2 flex gap-2 md:gap-3 z-20">
                    {slides.map((_, i) => (
                        <button
                            key={i}
                            onClick={() => api?.scrollTo(i)}
                            className={`transition-all duration-300 rounded-full ${i === current
                                ? 'w-7 h-2.5 md:w-8 md:h-3 bg-primary'
                                : 'w-2.5 h-2.5 md:w-3 md:h-3 bg-white/40 hover:bg-white/70'
                                }`}
                            aria-label={`Go to slide ${i + 1}`}
                        />
                    ))}
                </div>
            </Carousel>
        </section>
    )
}