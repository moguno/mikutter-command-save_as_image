#coding: utf-8

Plugin.create(:"mikutter-command-sava_as_image") {
  UserConfig[:save_as_image_folder] ||= Dir.home

  # コマンド
  command(:save_as_image,
        :name => _("画像として保存"),
        :condition => lambda { |opt| Plugin::Command[:HasMessage] },
        :visible => true,
        :role => :timeline) { |opt|

    begin
      pixbufs = opt.messages.map { |message|
        miracle_painter = Plugin[:gtk].widgetof(opt.widget).get_record_by_message(message).miracle_painter

        miracle_painter.on_unselected
        pixbuf = miracle_painter.gen_pixbuf
        miracle_painter.on_selected

        pixbuf
      }

      height = pixbufs.inject(0) { |sum, pixbuf| sum + pixbuf.height }

      pixmap = Gdk::Pixmap.new(nil, pixbufs.first.width, height, 24)
      context = pixmap.create_cairo_context

      pixbufs.each { |pixbuf|
        context.set_source_pixbuf(pixbuf)
        context.paint
        context.translate(0, pixbuf.height)
      }

      result_pixbuf = Gdk::Pixbuf.from_drawable(Gdk::Colormap.system, pixmap, 0, 0, pixbufs.first.width, height)

      filename = "#{opt.messages.first.user[:idname]}-#{opt.messages.first[:id_str]}.png"
      result_pixbuf.save(File.join(UserConfig[:save_as_image_folder], filename), "png")
    rescue => e
      puts e
      puts e.backtrace
    end
  }

  # 設定
  settings(_("画像として保存")) {
    input("保存フォルダ", :save_as_image_folder)
  }
}
