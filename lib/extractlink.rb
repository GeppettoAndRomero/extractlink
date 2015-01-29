#coding:utf-8
#require "extractlink/version"
require "kconv"
require "uri"

module ExtractLink
  def self.analyse(url,html)
    host = URI.parse(url).host rescue return
    html = html.toutf8
    link = if html =~ /<\/head\s*>/im
             html = $' #'
             extract_link($`)
           else
             extract_link(html)
           end
    body = Hash.new
    body = extract_href(url,html).merge(extract_iframe(url,html))
    body["link"] = link
    body["uri"] = url
    body
  end
  def self.extract_iframe(url,st)
    hash = Hash.new()
    hash["iframe_in"] = Array.new
    hash["iframe_out"] = Array.new
    st.scan(/<iframe.*?src=['"](.*?)['"]/im).each do |i|
      i = i[0]
      begin
        i = case i
            when /^http/
              i.to_s
            when /^\./
              URI.join(url,i).to_s
            when /^\//
              URI.join(url,i).to_s
            else
              next
            end
      rescue
        next
      end
      URI.parse(i) rescue next
      #end
      if URI.parse(i).host == URI.parse(url).host
        hash["iframe_in"].push i
      else
        hash["iframe_out"].push i
      end
    end
    hash
  end
  def self.extract_href(url,st)
    hash = Hash.new()
    hash["href_in"] = Array.new
    hash["href_out"] = Array.new
    st.scan(/<a.+?href=["'](.*?)['"].*?>(.*?)<\/a>/im).each do |i|
      i[1].gsub!(/[\r\n\t      ]/,"")
      i[1].gsub!(/<\/?[^>]*>/, "")
      #リンクテキスト　128文字制限
      i[1] = i[1][0..128]
      begin
        i[0] = case i[0]
               when /^http/
                 i[0].to_s
               when /^\./
                 URI.join(url,i[0]).to_s
               when /^\//
                 URI.join(url,i[0]).to_s
               else
                 next
               end
      rescue
        next
      end
      URI.parse(i[0]) rescue next
      if URI.parse(i[0]).host == URI.parse(url).host
        hash["href_in"].push i
      else
        hash["href_out"].push i
      end
    end
    hash
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

