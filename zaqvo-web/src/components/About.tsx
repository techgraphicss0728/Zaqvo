import bubbles from '@/assets/about.png'


export default function About() {
    return (
        <section className="py-16 px-6 max-w-7xl mx-auto">
            <div className="flex flex-col lg:flex-row gap-12 items-center">

                <div className="relative flex-1 min-h-[420px]">

                    {/* Main large image - water bottles */}
                    <div className="w-[100%] rounded-2xl overflow-hidden shadow-xl h-[420px]">
                        <img
                            src={bubbles}
                            alt="Pure water bottles"
                            className="w-full h-full object-cover"
                        />
                    </div>

                </div>

                {/* Content Side */}
                <div className="flex-1 space-y-5">
                    <p className="text-blue-500 font-semibold text-sm uppercase tracking-widest">About Us</p>
                    <h2 className="text-3xl lg:text-4xl font-bold text-gray-800 leading-tight">
                        We Always Want Safe and Healthy Water for Healthy Life
                    </h2>
                    <p className="text-gray-500 leading-relaxed">
                        At ZAQVO, we are redefining the way water reaches your doorstep.
                        We are a next-generation water delivery platform committed to providing pure, safe, and reliable drinking water—delivered to you within minutes. Our goal is simple: make access to clean water fast, convenient, and stress-free.
                        With features like real-time order tracking, 24/7 service, and affordable subscription plans, ZAQVO ensures a seamless experience for every customer. We combine technology and efficiency to deliver not just water, but trust and reliability.
                        We also care about the environment. That’s why we focus on eco-friendly packaging and sustainable practices to reduce our impact while maintaining high-quality service.
                        Whether for your home or workplace, ZAQVO is your trusted partner for everyday hydration.
                    </p>
                    <p className="text-gray-500 leading-relaxed">
                        ZAQVO – Pure Water. Instant Delivery.
                    </p>

                    {/* Stats */}
                    <div className="flex gap-8 pt-2">
                        {[['500+', 'Happy Clients'], ['99%', 'Purity Rate'], ['24/7', 'Support']].map(([num, label]) => (
                            <div key={label} className="text-center">
                                <p className="text-2xl font-bold text-blue-600">{num}</p>
                                <p className="text-sm text-gray-500 mt-1">{label}</p>
                            </div>
                        ))}
                    </div>
                </div>

            </div>
        </section>
    )
}