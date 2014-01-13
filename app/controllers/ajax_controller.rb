class AjaxController < ApplicationController
  def get_prices
    # prices_hash = {}
    # Product.find(params[:id].to_i).prices.each do |price|
    #   prices_hash[price.created_at.strftime("%m-%d")] = price.value.to_f
    # end
    prices_hash = {"历史最低" => Product.find(params[:id].to_i).low_price}.merge(Product.find(params[:id].to_i).price_history || {})
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
    # f.title({ :text=>"价格走势"})
    f.options[:xAxis][:categories] = prices_hash.keys.map{ |date| date.split("-").last == "01" ? date : date.split("-").last }
    f.series(:type=> 'spline',:name=> '价格走势', :data=> prices_hash.values.map{ |v| v.to_f })
    end
  end
end