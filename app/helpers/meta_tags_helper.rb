module MetaTagsHelper
  def meta_title
    content_for?(:title_tag) ? content_for(:title_tag) : "Les #{ENV['MODEL']} de #{ENV['FIRSTNAME'].capitalize} #{ENV['LASTNAME'].capitalize}"
  end

  def meta_product_name
    content_for?(:meta_product_name) ? content_for(:meta_product_name) : "Les #{ENV['MODEL']} de #{ENV['FIRSTNAME'].capitalize} #{ENV['LASTNAME'].capitalize} - vente de produits de l'artisanat"
  end

  def meta_description
    description = "Des produits extraordinaires. Décor somptueux. Venez découvrir leur fabrication lors d'un stage."
    content_for?(:description) ? content_for(:description) : description
  end

  def meta_image
    meta_image = (content_for?(:meta_image) ? content_for(:meta_image).strip : image_path(ENV['HOMEPIC']))
    # little twist to make it work equally with an asset or a url
    meta_image.starts_with?("http") ? meta_image : image_url(meta_image)
  end
end

