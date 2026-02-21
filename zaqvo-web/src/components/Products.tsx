import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'

const products = [
    {
        image: 'https://placehold.co/300x300/257eb8/ffffff?text=2L+Bottle',
        badge: '2L 3 Bottles',
        name: 'Mineral Water Bottle',
        // price: '$12.99',
        description: 'Premium mineral water with essential minerals. Perfect for daily hydration and healthy living.',
    },
    {
        image: 'https://placehold.co/300x300/282e52/ffffff?text=5L+Pack',
        badge: '5L 2 Bottles',
        name: 'Pure Spring Water Pack',
        // price: '$18.99',
        description: 'Natural spring water sourced from pristine mountain springs. Crisp, clean, and refreshing.',
    },
    {
        image: 'https://placehold.co/300x300/257eb8/ffffff?text=1L+6+Pack',
        badge: '1L 6 Bottles',
        name: 'Alkaline Water Bundle',
        // price: '$15.99',
        description: 'Alkaline water with a pH of 8.5+. Supports hydration and overall wellness.',
    },
]

export default function Products() {
    return (
        <section id="products" className="py-20 px-4 md:px-8 bg-gray-50">
            <div className="max-w-7xl mx-auto">
                <div className="text-center mb-14">
                    <span className="text-primary font-semibold text-sm tracking-widest uppercase">Our Products</span>
                    <h2 className="text-3xl md:text-4xl font-extrabold text-dark mt-2">
                        We Deliver Best Quality Bottle Packs
                    </h2>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                    {products.map((product) => (
                        <Card key={product.name} className="overflow-hidden group hover:shadow-xl transition-shadow duration-300">
                            <div className="relative overflow-hidden">
                                <img
                                    src={product.image}
                                    alt={product.name}
                                    className="w-full h-56 object-cover group-hover:scale-105 transition-transform duration-500"
                                />
                                <div className="absolute top-4 left-4">
                                    <Badge className="bg-primary text-white text-xs font-semibold">{product.badge}</Badge>
                                </div>
                            </div>
                            <CardContent className="p-6">
                                <h3 className="text-dark font-bold text-xl mb-1">{product.name}</h3>
                                {/* <p className="text-primary font-extrabold text-2xl mb-3">{product.price}</p> */}
                                <p className="text-gray-500 text-sm mb-5 leading-relaxed">{product.description}</p>
                                {/* <Button className="w-full bg-primary hover:bg-primary/90 text-white font-semibold gap-2">
                                    <ShoppingCart className="w-4 h-4" />
                                    Add to Cart
                                </Button> */}
                            </CardContent>
                        </Card>
                    ))}
                </div>
            </div>
        </section>
    )
}
