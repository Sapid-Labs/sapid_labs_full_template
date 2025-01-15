import { FunctionalComponent } from "preact";

interface TwoColumnSectionProps {
  title: string;
  subtitle: string;
  imageUrl: string;
  imageLeft: boolean;
}

export const TwoColumnSection: FunctionalComponent<TwoColumnSectionProps> = ({
  title,
  subtitle,
  imageUrl,
  imageLeft,
}) => {
  const textColumn = (
    <div>
      <h2 class="text-3xl font-bold mb-4">{title}</h2>
      <p class="text-gray-600">{subtitle}</p>
    </div>
  );

  const imageColumn = (
    <div class="flex justify-center">
      <img src={imageUrl} alt={title} class="max-w-full h-auto" />
    </div>
  );

  // For small screens, default is text on top (order-1), image on bottom (order-2).
  // For md screens and above, if imageLeft = true:
  //   - image gets md:order-1
  //   - text gets  md:order-2
  // Otherwise, text is md:order-1 and image is md:order-2.
  const imageClasses = imageLeft ? "order-2 md:order-1" : "order-2 md:order-2";
  const textClasses = imageLeft ? "order-1 md:order-2" : "order-1 md:order-1";

  return (
    <section class="py-12">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">
          {/* Image block */}
          <div class={imageClasses}>{imageColumn}</div>
          {/* Text block */}
          <div class={textClasses}>{textColumn}</div>
        </div>
      </div>
    </section>
  );
};
