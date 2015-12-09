module ImageHelper
  def overlay_image(filename)
    dst = Magick::Image.read("photo.jpg") {self.size = "640x480"}.first
    src = Magick::Image.read(filename).first
    result = dst.composite(src, Magick::CenterGravity, Magick::OverCompositeOp)
    result.write('photo.jpg')
  end
end