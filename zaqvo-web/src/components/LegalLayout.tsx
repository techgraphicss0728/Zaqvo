import React from "react";

interface LegalLayoutProps {
    title: string;
    date?: string;
    children: React.ReactNode;
}

const LegalLayout: React.FC<LegalLayoutProps> = ({ title, date, children }) => {
    return (
        <div className="bg-white min-h-screen py-16 px-4">
            <div className="max-w-3xl mx-auto">

                <h1 className="text-3xl font-bold mb-2">{title}</h1>

                {date && (
                    <p className="text-gray-500 mb-8">
                        Effective Date: {date}
                    </p>
                )}

                <div className="space-y-6 text-gray-700 leading-7">
                    {children}
                </div>

            </div>
        </div>
    );
};

export default LegalLayout;