import { useEffect, useRef, useState } from 'react'
import { Star, Quote } from 'lucide-react'
import { Carousel, CarouselContent, CarouselItem, type CarouselApi } from '@/components/ui/carousel'
import { Card, CardContent } from '@/components/ui/card'
import Autoplay from 'embla-carousel-autoplay'

const testimonials = [
    {
        name: 'Raju',
        role: 'Homeowner',
        avatar: 'https://placehold.co/60x60/257eb8/ffffff?text=SJ',
        quote: 'Zaqvo has completely transformed the water quality in our home. The difference in taste and clarity is remarkable. Our family feels healthier and more energized!',
        rating: 5,
    },
    {
        name: 'Sai Kiran',
        role: 'Restaurant Owner',
        avatar: 'https://placehold.co/60x60/282e52/ffffff?text=MC',
        quote: 'As a restaurant owner, water quality is paramount. Zaqvo\'s commercial system has improved our food quality and our customers have noticed the difference.',
        rating: 5,
    },
    {
        name: 'Sai Prasad',
        role: 'Office Manager',
        avatar: 'https://placehold.co/60x60/257eb8/ffffff?text=ER',
        quote: 'The delivery service is incredibly reliable and the water quality is outstanding. Our employees love having access to pure, clean water throughout the day.',
        rating: 5,
    },
]

export default function Testimonials() {
    const [api, setApi] = useState<CarouselApi>()
    const [current, setCurrent] = useState(0)
    const plugin = useRef(Autoplay({ delay: 4000, stopOnInteraction: false }))

    useEffect(() => {
        if (!api) return
        api.on('select', () => setCurrent(api.selectedScrollSnap()))
    }, [api])

    return (
        <section className="py-20 px-4 md:px-8 bg-gray-100">
            <div className="max-w-7xl mx-auto">
                <div className="text-center mb-14">
                    <span className="text-primary font-semibold text-sm tracking-widest uppercase">Testimonials</span>
                    <h2 className="text-3xl md:text-4xl font-extrabold text-dark mt-2">
                        What Our Clients are Saying
                    </h2>
                </div>

                <Carousel
                    setApi={setApi}
                    plugins={[plugin.current]}
                    opts={{ loop: true }}
                    className="w-full"
                >
                    <CarouselContent>
                        {testimonials.map((t, index) => (
                            <CarouselItem key={index} className="md:basis-1/2 lg:basis-1/3">
                                <Card className="h-full border-0 shadow-md hover:shadow-xl transition-shadow duration-300">
                                    <CardContent className="p-8 flex flex-col h-full">
                                        <Quote className="w-10 h-10 text-primary/30 mb-4" />
                                        {/* Stars */}
                                        <div className="flex gap-1 mb-4">
                                            {Array.from({ length: t.rating }).map((_, i) => (
                                                <Star key={i} className="w-4 h-4 text-yellow-400 fill-yellow-400" />
                                            ))}
                                        </div>
                                        <p className="text-gray-600 text-sm leading-relaxed flex-1 mb-6 italic">
                                            "{t.quote}"
                                        </p>
                                        <div className="flex items-center gap-4">
                                            <img
                                                src={t.avatar}
                                                alt={t.name}
                                                className="w-12 h-12 rounded-full object-cover border-2 border-primary"
                                            />
                                            <div>
                                                <div className="font-bold text-dark text-sm">{t.name}</div>
                                                <div className="text-gray-500 text-xs">{t.role}</div>
                                            </div>
                                        </div>
                                    </CardContent>
                                </Card>
                            </CarouselItem>
                        ))}
                    </CarouselContent>
                </Carousel>

                {/* Dots */}
                <div className="flex justify-center gap-2 mt-8">
                    {testimonials.map((_, i) => (
                        <button
                            key={i}
                            onClick={() => api?.scrollTo(i)}
                            className={`transition-all duration-300 rounded-full ${i === current ? 'w-6 h-2.5 bg-primary' : 'w-2.5 h-2.5 bg-gray-300 hover:bg-primary/50'
                                }`}
                            aria-label={`Go to testimonial ${i + 1}`}
                        />
                    ))}
                </div>
            </div>
        </section>
    )
}
