require 'benchmark'

RSpec.describe do
  it 'hash table' do
    table = HashTable::HashTable.new(2)
    table.set(3, 7, HashTable::IdentityHashTraits.new)
    table.set(4, 5, HashTable::IdentityHashTraits.new)
    table.set(5, 6, HashTable::IdentityHashTraits.new)
    table.set(6, 7, HashTable::IdentityHashTraits.new)
    table.set(8, 9, HashTable::IdentityHashTraits.new)
    table.set(9, 19, HashTable::IdentityHashTraits.new)
    expect(table.size).to eq(6)
    expect(table.get(3, HashTable::IdentityHashTraits.new)).to eq(7)
    expect(table.get(4, HashTable::IdentityHashTraits.new)).to eq(5)
    expect(table.get(5, HashTable::IdentityHashTraits.new)).to eq(6)
    expect(table.get(6, HashTable::IdentityHashTraits.new)).to eq(7)
    expect(table.get(8, HashTable::IdentityHashTraits.new)).to eq(9)
    expect(table.get(9, HashTable::IdentityHashTraits.new)).to eq(19)
    expect(table.capacity).to eq(16)
  end

  it 'hash string table' do
    table = HashTable::HashTable.new(2)
    traits = HashTable::StringIdentityHashTraits.new
    table.set('ViewController64.h', 'ViewController64.h', traits)
    table.set('ViewController65.h', 'ViewController65.h', traits)
    table.set('ViewController66.h', 'ViewController66.h', traits)
    table.set('ViewController67.h', 'ViewController67.h', traits)
    table.set('ViewController68.h', 'ViewController68.h', traits)
    table.set('ViewController69.h', 'ViewController69.h', traits)
    expect(table.size).to eq(6)
    expect(table.get('ViewController64.h', traits)).to eq('ViewController64.h')
    expect(table.get('ViewController65.h', traits)).to eq('ViewController65.h')
    expect(table.get('ViewController66.h', traits)).to eq('ViewController66.h')
    expect(table.get('ViewController67.h', traits)).to eq('ViewController67.h')
    expect(table.get('ViewController68.h', traits)).to eq('ViewController68.h')
    expect(table.get('ViewController69.h', traits)).to eq('ViewController69.h')
    expect(table.capacity).to eq(16)
    expect(traits.string_table).to eq("\u0000ViewController64.h\u0000ViewController65.h\u0000ViewController66.h\u0000ViewController67.h\u0000ViewController68.h\u0000ViewController69.h\u0000")
  end

  it 'hash string table add' do
    table = HashTable::HashTable.new
    traits = HashTable::StringIdentityHashTraits.new
    (0..31).each do |i|
      table.add("ViewController#{i}.h", traits)
    end
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(32)
    expect(table.capacity).to eq(64)
    expect(table.num_entries).to eq(32)
  end

  it 'hash string table 86 expand add' do
    table = HashTable::HashTable.new(expand: true)
    traits = HashTable::StringIdentityHashTraits.new
    (0..85).each do |i|
      table.add("ViewController#{i}.h", traits)
    end
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(86)
    expect(table.capacity).to eq(512)
    expect(table.num_entries).to eq(257)
  end

  it 'hash string table 341 expand add' do
    table = HashTable::HashTable.new(expand: true)
    traits = HashTable::StringIdentityHashTraits.new
    (0..340).each do |i|
      table.add("ViewController#{i}.h", traits)
    end
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(341)
    expect(table.capacity).to eq(2048)
    expect(table.num_entries).to eq(1025)
  end

  it 'hash string table 1364 6expand add' do
    table = HashTable::HashTable.new(1364, expand: true)
    traits = HashTable::StringIdentityHashTraits.new
    (0..1363).each do |i|
      table.add("ViewController#{i}.h", traits)
    end
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(1364)
    expect(table.capacity).to eq(8192)
    expect(table.num_entries).to eq(4097)
  end

  it 'hash string table expand adds' do
    table = HashTable::HashTable.new(expand: true)
    traits = HashTable::StringIdentityHashTraits.new
    bucket = table.adds(%w[TestAndTestApp/ViewController.h
                           /Users/ws/Desktop/llvm/TestAndTestApp/TestAndTestApp/Group/h2/
                           ViewController.h], traits)
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(3)
    expect(table.capacity).to eq(8)
    expect(table.num_entries).to eq(3)
    expect(traits.string_table).to eq("\u0000TestAndTestApp/ViewController.h\u0000/Users/ws/Desktop/llvm/TestAndTestApp/TestAndTestApp/Group/h2/\u0000ViewController.h\u0000")
    expect(bucket).to eq([1, 33, 96])
  end

  it 'hash string table expand adds' do
    table = HashTable::HashTable.new(expand: true)
    traits = HashTable::StringIdentityHashTraits.new
    buckets = (0..1363).map do |i|
      a = ["ViewController#{i}.h", "/Users/ws/Desktop/llvm/TestAndTestApp/TestAndTestApp/Group/h2/#{i}",
           "ViewController#{i}.h"]
      table.adds(a, traits)
    end
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(2728)
    expect(table.capacity).to eq(8192)
    expect(table.num_entries).to eq(5461)
  end
  it 'hash string table expand adds' do
    table = HashTable::HashTable.new(1364, expand: true)
    traits = HashTable::StringHashTraits.new
    buckets = (0..1363).map do |i|
    table.set("ViewController#{i}.h",
                ["/Users/ws/Desktop/llvm/TestAndTestApp/TestAndTestApp/Group/h2/#{i}", "ViewController#{i}.h"], traits)
    end
    p "#{table.size}---#{table.capacity}----#{table.num_entries}"
    expect(table.size).to eq(1364)
    expect(table.capacity).to eq(8192)
    expect(table.num_entries).to eq(4097)
  end

  it 'hash string table expand adds' do
    table = HashTable::HashTable.new(343, expand: true)
    traits = HashTable::StringHashTraits.new
    Benchmark.bm(7) do |x|
      x.report('add:') do
        (0..342).each do |i|
          table.add("ViewController#{i}.h", traits)
        end
        p "#{table.size}---#{table.capacity}----#{table.num_entries}"
      end
    end
  end

  it 'hash string table expand adds' do
    Benchmark.bm(7) do |x|
      x.report('set:') do
        m = [["AFNetworking/AFAutoPurgingImageCache.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "AFAutoPurgingImageCache.h"], ["AFNetworking/UIKit+AFNetworking/AFAutoPurgingImageCache.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "AFAutoPurgingImageCache.h"], ["UIKit+AFNetworking/AFAutoPurgingImageCache.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "AFAutoPurgingImageCache.h"], ["AFAutoPurgingImageCache.h", "AFNetworking/", "AFAutoPurgingImageCache.h"], ["AFNetworking/AFNetworking/AFCompatibilityMacros.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFCompatibilityMacros.h"], ["AFNetworking/AFCompatibilityMacros.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFCompatibilityMacros.h"], ["AFCompatibilityMacros.h", "AFNetworking/", "AFCompatibilityMacros.h"], ["AFNetworking/AFNetworking/AFHTTPSessionManager.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFHTTPSessionManager.h"], ["AFNetworking/AFHTTPSessionManager.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFHTTPSessionManager.h"], ["AFHTTPSessionManager.h", "AFNetworking/", "AFHTTPSessionManager.h"], ["AFNetworking/AFImageDownloader.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "AFImageDownloader.h"], ["AFNetworking/UIKit+AFNetworking/AFImageDownloader.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "AFImageDownloader.h"], ["UIKit+AFNetworking/AFImageDownloader.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "AFImageDownloader.h"], ["AFImageDownloader.h", "AFNetworking/", "AFImageDownloader.h"], ["AFNetworking/AFNetworkActivityIndicatorManager.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "AFNetworkActivityIndicatorManager.h"], ["AFNetworking/UIKit+AFNetworking/AFNetworkActivityIndicatorManager.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "AFNetworkActivityIndicatorManager.h"], ["UIKit+AFNetworking/AFNetworkActivityIndicatorManager.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "AFNetworkActivityIndicatorManager.h"], ["AFNetworkActivityIndicatorManager.h", "AFNetworking/", "AFNetworkActivityIndicatorManager.h"], ["AFNetworking/AFNetworking/AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFNetworking.h"], ["AFNetworking/AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFNetworking.h"], ["AFNetworking.h", "AFNetworking/", "AFNetworking.h"], ["AFNetworking/AFNetworking-umbrella.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/Target Support Files/AFNetworking/", "AFNetworking-umbrella.h"], ["AFNetworking/../Target Support Files/AFNetworking/AFNetworking-umbrella.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/Target Support Files/AFNetworking/", "AFNetworking-umbrella.h"], ["AFNetworking-umbrella.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/Target Support Files/AFNetworking/", "AFNetworking-umbrella.h"], ["AFNetworking-umbrella.h", "AFNetworking/", "AFNetworking-umbrella.h"], ["AFNetworking/AFNetworking/AFNetworkReachabilityManager.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFNetworkReachabilityManager.h"], ["AFNetworking/AFNetworkReachabilityManager.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFNetworkReachabilityManager.h"], ["AFNetworkReachabilityManager.h", "AFNetworking/", "AFNetworkReachabilityManager.h"], ["AFNetworking/AFNetworking/AFSecurityPolicy.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFSecurityPolicy.h"], ["AFNetworking/AFSecurityPolicy.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFSecurityPolicy.h"], ["AFSecurityPolicy.h", "AFNetworking/", "AFSecurityPolicy.h"], ["AFNetworking/AFNetworking/AFURLRequestSerialization.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFURLRequestSerialization.h"], ["AFNetworking/AFURLRequestSerialization.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFURLRequestSerialization.h"], ["AFURLRequestSerialization.h", "AFNetworking/", "AFURLRequestSerialization.h"], ["AFNetworking/AFNetworking/AFURLResponseSerialization.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFURLResponseSerialization.h"], ["AFNetworking/AFURLResponseSerialization.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFURLResponseSerialization.h"], ["AFURLResponseSerialization.h", "AFNetworking/", "AFURLResponseSerialization.h"], ["AFNetworking/AFNetworking/AFURLSessionManager.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFURLSessionManager.h"], ["AFNetworking/AFURLSessionManager.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/AFNetworking/", "AFURLSessionManager.h"], ["AFURLSessionManager.h", "AFNetworking/", "AFURLSessionManager.h"], ["AFNetworking/UIActivityIndicatorView+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIActivityIndicatorView+AFNetworking.h"], ["AFNetworking/UIKit+AFNetworking/UIActivityIndicatorView+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIActivityIndicatorView+AFNetworking.h"], ["UIKit+AFNetworking/UIActivityIndicatorView+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIActivityIndicatorView+AFNetworking.h"], ["UIActivityIndicatorView+AFNetworking.h", "AFNetworking/", "UIActivityIndicatorView+AFNetworking.h"], ["AFNetworking/UIButton+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIButton+AFNetworking.h"], ["AFNetworking/UIKit+AFNetworking/UIButton+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIButton+AFNetworking.h"], ["UIKit+AFNetworking/UIButton+AFNetworking.h", "/Users/ws/Desktop/代���混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIButton+AFNetworking.h"], ["UIButton+AFNetworking.h", "AFNetworking/", "UIButton+AFNetworking.h"], ["AFNetworking/UIImageView+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIImageView+AFNetworking.h"], ["AFNetworking/UIKit+AFNetworking/UIImageView+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIImageView+AFNetworking.h"], ["UIKit+AFNetworking/UIImageView+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIImageView+AFNetworking.h"], ["UIImageView+AFNetworking.h", "AFNetworking/", "UIImageView+AFNetworking.h"], ["AFNetworking/UIKit+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIKit+AFNetworking.h"], ["AFNetworking/UIKit+AFNetworking/UIKit+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIKit+AFNetworking.h"], ["UIKit+AFNetworking/UIKit+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIKit+AFNetworking.h"], ["UIKit+AFNetworking.h", "AFNetworking/", "UIKit+AFNetworking.h"], ["AFNetworking/UIProgressView+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIProgressView+AFNetworking.h"], ["AFNetworking/UIKit+AFNetworking/UIProgressView+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIProgressView+AFNetworking.h"], ["UIKit+AFNetworking/UIProgressView+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIProgressView+AFNetworking.h"], ["UIProgressView+AFNetworking.h", "AFNetworking/", "UIProgressView+AFNetworking.h"], ["AFNetworking/UIRefreshControl+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIRefreshControl+AFNetworking.h"], ["AFNetworking/UIKit+AFNetworking/UIRefreshControl+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIRefreshControl+AFNetworking.h"], ["UIKit+AFNetworking/UIRefreshControl+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "UIRefreshControl+AFNetworking.h"], ["UIRefreshControl+AFNetworking.h", "AFNetworking/", "UIRefreshControl+AFNetworking.h"], ["AFNetworking/WKWebView+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "WKWebView+AFNetworking.h"], ["AFNetworking/UIKit+AFNetworking/WKWebView+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "WKWebView+AFNetworking.h"], ["UIKit+AFNetworking/WKWebView+AFNetworking.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/AFNetworking/UIKit+AFNetworking/", "WKWebView+AFNetworking.h"], ["WKWebView+AFNetworking.h", "AFNetworking/", "WKWebView+AFNetworking.h"], ["Pods_LGApp/Pods-LGApp-umbrella.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/Target Support Files/Pods-LGApp/", "Pods-LGApp-umbrella.h"], ["Target Support Files/Pods-LGApp/Pods-LGApp-umbrella.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/Target Support Files/Pods-LGApp/", "Pods-LGApp-umbrella.h"], ["Pods-LGApp-umbrella.h", "/Users/ws/Desktop/代码混淆/01-单文件编译/LGApp/Pods/Target Support Files/Pods-LGApp/", "Pods-LGApp-umbrella.h"], ["Pods-LGApp-umbrella.h", "Pods_LGApp/", "Pods-LGApp-umbrella.h"]]
        table = HashTable::HashTable.new_from_vlaue_placeholder(m.length, "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", expand: true)

        traits = HashTable::StringHashTraits.new
        m.each do |i|
          table.set(i[0], i[1..], traits)
        end
      end
    end
  end
end
