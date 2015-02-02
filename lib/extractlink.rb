#coding:utf-8
#require "extractlink/version"
require "kconv"
require "uri"

module ExtractLink
  def self.analyse(html)
    html = html.toutf8
    link = if html =~ /<\/head\s*>/im
             html = $' #'
             extract_link($`)
           else
             extract_link(html)
           end
    href = extract_href(html)
    iframe = extract_iframe(html)
    [href,iframe,link]
  end
  def self.extract_iframe(st)
    hash = Array.new()
    st.scan(/<iframe.*?src=['"](.*?)['" >\r]/im).each do |i,ii|
      i = case i
          when /^http/
            i.to_s
          when /^\./
            i.to_s
          when /^\//
            i.to_s
          else
            next
          end
      hash.push i
    end
    hash
  end
  def self.extract_href(st)
    link = []
    st.scan(/<a.+?href=["'](.*?)['"].*?>(.*?)<\/a>/im).each do |i|
      i[1].gsub!(/[\r\n\t      ]/,"")
      i[1].gsub!(/<\/?[^>]*>/, "")
      #リンクテキスト　128文字制限
      i[1] = i[1][0..128]
        i[0] = case i[0]
               when /^http/
                 i[0].to_s
               when /^\./
                 i[0].to_s
               when /^\//
                 i[0].to_s
               else
                 next
               end
        link.push i#[0]
    end
    link
  end

  def self.extract_link(st)
    links = Array.new
    link = st.scan(/(<link.*?>)/im)
    link.each do |i|
      hash = Hash.new
      i[0].scan(/(\w+)+=["|'](.*?)['|"]/).each do |i|
        hash[i[0]] = i[1]
      end
      links.push hash
    end
    links
  end
end

