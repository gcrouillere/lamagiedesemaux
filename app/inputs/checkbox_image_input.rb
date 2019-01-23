class CheckboxImageInput < Formtastic::Inputs::CheckBoxesInput
  include CloudinaryHelper
  def choice_html(choice)
    template.content_tag(
      :label,
      img_tag(choice) + checkbox_input(choice) + choice_label(choice),
      label_html_options.merge(:for => choice_input_dom_id(choice), :class => "input_with_thumbnail")
    )
  end

  def img_tag(choice)
    cl_image_tag(Ceramique.find(choice.gsub("ID: ","").to_i).photos[0].path, :width=>100, :height=>100, :crop=>"fill")
  end
end
