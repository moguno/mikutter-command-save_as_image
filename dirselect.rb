#coding: utf-8

class Plugin::Settings
  # ファイルを選択する
  # ==== Args
  # [label] ラベル
  # [config] 設定のキー
  # [current] 初期のディレクトリ
  def dirselect(label, config, current=Dir.pwd)
    container = input(label, config)
    input = container.children.last.children.first
    button = Gtk::Button.new('参照')
    container.pack_start(button, false)
    button.signal_connect('clicked'){ |widget|
      dialog = Gtk::FileChooserDialog.new("Open File",
                                          widget.get_ancestor(Gtk::Window),
                                          Gtk::FileChooser::ACTION_SELECT_FOLDER,
                                          nil,
                                          [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                          [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
      dialog.current_folder = File.expand_path(current)
      if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
        Listener[config].set dialog.filename
        input.text = dialog.filename
      end
      dialog.destroy
    }
    container
  end
end
