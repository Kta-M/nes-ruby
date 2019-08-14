# frozen_string_literal: true

require 'logger'
require 'pry'
require './ppu_colors'

# ディスプレイクラス
class Display
  def initialize(logger)
    @logger = logger
  end

  # 画面表示
  def render(screen)
    bw_screen = screen.map do |line|
      line.map do |pixel|
        pixel.sum < 384 ? 0 : 1
      end
    end
    brailles = bw_screen.each_slice(4).to_a.map { |line|
      line.transpose.each_slice(2).to_a.map { |braille|
        # [[1, 2, 3, 7], [4, 5, 6, 8]]
        braille_bits = [
          braille[1][3],
          braille[0][3],
          braille[1][2],
          braille[1][1],
          braille[1][0],
          braille[0][2],
          braille[0][1],
          braille[0][0]
        ]
        (braille_bits.join.to_i(2) + 0x2800).chr('UTF-8')
      }.join
    }.join("\n")

    puts brailles
  end
end
