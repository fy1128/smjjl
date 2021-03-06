class ProductList::Newegg < ProductList
  # extends ...................................................................
  # includes ..................................................................
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  # validations ...............................................................
  # callbacks .................................................................
  # scopes ....................................................................
  # additional config .........................................................
  # class methods .............................................................
  # public instance methods ...................................................
  def list_url
    url
  end
  
  # 获取分页的初始页
  def get_pagination(category = "id")
    total_page = Nokogiri::HTML(http_get("#{url}?sort=50&pageSize=96"), nil, "GBK").css(".innerb ins").text.scan(%r|/(\d+)|).first.first.to_i rescue 1
    1.upto total_page do |page_num|
      GetIdWorker.perform_async(id, page_num) if category == "id"
      UpdateListPriceWorker.perform_async(id, page_num) if category == "price"
    end
  end

  # 在列表中获取product id
  def get_product_ids(page_num)
    page_url = url.gsub(".htm", "-#{page_num}.htm?sort=50&pageSize=96")
    Nokogiri::HTML(http_get(page_url), nil, "GBK").css(".catepro p.title a").each do |a|
      Product::Newegg.create(url: a.attr("href"))
    end
  end

  # 从列表中更新价格及其他信息
  def get_list_prices(page_num)
    page_url = url.gsub(".htm", "-#{page_num}.htm?sort=50&pageSize=96")
    Nokogiri::HTML(http_get(page_url), nil, "GBK").css(".catepro li.cls").each do |li|
      next if li.css("p.title a").blank?
      next unless product = Product::Newegg.where(url: li.css("p.title a").attr("href").to_s.strip).first
      name = li.css(".title a").text.strip rescue nil
      # 如果名称发生巨大变化，则证明原商品已被替换，进行下架处理
      if product.name.blank? || (name && product.name.similar(name) > 85)
        product.name = name
        product.count = li.css('.rank').text.scan(%r|\d+|).first rescue nil
        product.score = li.css('.rank a').attr("title").text.scan(%r|[\d\.]+|).first rescue nil
        product.save
        product.record_price li.css('.price').text.scan(/[\d\.]+/).join
      else
        product.update_columns(url_key: nil, url: nil, is_discontinued: true)
      end
    end
  end

  # protected instance methods ................................................
  # private instance methods ..................................................
end
