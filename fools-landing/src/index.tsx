import { render } from "preact";
import appStoreBadge from "./assets/app-store-badge.svg";
import playStoreBadge from "./assets/play-store-badge.png";
import homeImage from "./assets/mockup-home.png";
import logo from "./assets/cup-cake.png";
import ingredientsImage from "./assets/mockup-ingredients.png";
import booksImage from "./assets/mockup-books.png";
import instructionsImage from "./assets/mockup-instructions.png";
import "./style.css";
import { TwoColumnSection } from "./TwoColumnSection";

const googlePlayUrl =
  "https://play.google.com/store/apps/details?id=com.mullr.abis_recipes&hl=en-US";
const appStoreUrl = "https://apps.apple.com/us/app/fools/id6445965871";

interface StoreButtonProps {
  href: string;
  src: string;
  alt: string;
}

const StoreButton = ({ href, src, alt }: StoreButtonProps) => (
  <a
    href={href}
    target="_blank"
    rel="noopener noreferrer"
    class="transition-transform hover:scale-105 text-start"
  >
    <img src={src} alt={alt} class="h-12" />
  </a>
);

export function App() {
  return (
    <div class="min-h-screen bg-white text-gray-900 flex flex-col">
      {/* Header */}
      <header class="fixed w-full top-0 bg-white/80 backdrop-blur-sm z-10">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          {/* 
      Use flex-col (vertical) on mobile, then flex-row on md+ screens
      Also remove "items-center" to allow each row to size/align independently
    */}
          <div class="flex flex-col md:flex-row justify-between py-4">
            {/* Logo + Title row */}
            <div class="flex items-center space-x-2">
              <img src={logo} alt="Fools logo" class="h-8 w-8" />
              <span class="text-xl font-bold">Fools</span>
            </div>

            {/* Store Buttons row */}
            {/* 
        Add mt-4 on mobile so there's spacing between the logo/title 
        and store buttons. On md screens and up (md:mt-0), remove it.
      */}
            <div class="hidden md:flex flex-col md:flex-row md:space-x-4 max-md:space-y-3 mt-4 md:mt-0">
              <StoreButton
                href={appStoreUrl}
                src={appStoreBadge}
                alt="Download on the App Store"
              />
              <StoreButton
                href={googlePlayUrl}
                src={playStoreBadge}
                alt="Get it on Google Play"
              />
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main class="pt-24 flex-grow">
        {/* Hero Section */}
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="lg:grid lg:grid-cols-2 lg:gap-8 lg:items-center">
            {/* Left Column */}
            <div class="mb-12 lg:mb-0">
              <h1 class="text-4xl sm:text-5xl lg:text-6xl font-bold mb-6">
                Clear away the clutter from your baking
              </h1>
              <p class="text-xl text-gray-600 mb-8">
                Get your recipes organized without the fluff. No more endless
                scrolling, just the ingredients and steps you need.
              </p>
              <div class="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4">
                <StoreButton
                  href={appStoreUrl}
                  src={appStoreBadge}
                  alt="Download on the App Store"
                />
                <StoreButton
                  href={googlePlayUrl}
                  src={playStoreBadge}
                  alt="Get it on Google Play"
                />
              </div>
            </div>
            {/* Right Column - Phone Mockup */}
            <div class="relative">
              <div class="relative mx-auto max-w-[366px]">
                <img src={homeImage} alt="Fools app interface" class="w-full" />
              </div>
            </div>
          </div>
        </div>

        {/* Why Fools? Benefits Section */}
        <section class="mt-16 py-12 bg-gray-50">
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h2 class="text-3xl font-bold mb-8">Why Fools?</h2>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-10">
              <div>
                <h3 class="text-xl font-semibold">Organized Recipes</h3>
                <p class="text-gray-600 mt-2">
                  Keep all your favorite recipes in one place, so you can focus
                  on perfecting your bakes instead of hunting for ingredients.
                </p>
              </div>
              <div>
                <h3 class="text-xl font-semibold">Minimal Distractions</h3>
                <p class="text-gray-600 mt-2">
                  Enjoy a clutter-free interface that shows only what you need—
                  no pop-ups, ads, or unnecessary scrolling.
                </p>
              </div>
              <div>
                <h3 class="text-xl font-semibold">Save & Share</h3>
                <p class="text-gray-600 mt-2">
                  Easily save recipes and share them with friends. Because
                  everything tastes better when shared.
                </p>
              </div>
            </div>
          </div>
        </section>

        <section>
          <TwoColumnSection
            title="Clear away the clutter"
            subtitle="Just the recipes you love, without endless scrolling or popups. Because baking should be about flour on your hands, not fingers on a screen."
            imageUrl={ingredientsImage}
            imageLeft={false}
          />

          <TwoColumnSection
            title="Create Recipe Books"
            subtitle="Organize your recipes into books for easy access. Create a book for each occasion, category, or style."
            imageUrl={booksImage}
            imageLeft={true}
          />
          <TwoColumnSection
            title="Just a Pinch of AI"
            subtitle="Merge ingredients and instructions, extract recipe components, and shorten steps with our AI-powered recipe parser."
            imageUrl={instructionsImage}
            imageLeft={false}
          />
        </section>

        {/* Additional CTA Section */}
        <section class="py-12">
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="bg-gray-100 rounded-xl p-8 flex flex-col md:flex-row items-center justify-between">
              <div class="mb-6 md:mb-0 md:mr-6">
                <h2 class="text-2xl font-bold mb-2">
                  Ready to simplify your baking?
                </h2>
                <p class="text-gray-600">
                  Download Fools and enjoy a clean, organized cooking
                  experience.
                </p>
              </div>
              <div class="flex flex-col md:flex-row md:space-x-4 space-y-2 md:space-y-0 items-start text-left">
                <StoreButton
                  href={appStoreUrl}
                  src={appStoreBadge}
                  alt="Download on the App Store"
                />
                <StoreButton
                  href={googlePlayUrl}
                  src={playStoreBadge}
                  alt="Get it on Google Play"
                />
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer class="bg-white py-6 border-t border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <p class="text-sm text-gray-500">
            &copy; {new Date().getFullYear()} Fools. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}

render(<App />, document.getElementById("app"));
