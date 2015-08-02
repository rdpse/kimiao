#!/usr/bin/env ruby
#encoding: utf-8

require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'io/console'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
        :window_size => [1024, 768],
        :timeout => 180,
        :phantomjs_options =>
        [ '--load-images=true','--ignore-ssl-errors=yes'])
end

Capybara.javascript_driver = :poltergeist
Capybara.current_driver = :poltergeist
Capybara.default_wait_time = 10

$svmodels = {
    "KS-1"              =>    "150sk10",
    "KS-2"              =>    "150sk20",
    "KS-2 SSD"      =>    "150sk22",
    "KS-3"              =>    "150sk30",
    "KS-4"              =>    "150sk40",
    "KS-5"              =>    "150sk50",
    "KS-6"              =>    "150sk60",

    "SYS-IP-1"       =>    "142sys4",
    "SYS-IP-2"       =>    "142sys5",
    "SYS-IP-4"       =>    "142sys8",
    "SYS-IP-5"       =>    "142sys6",
    "SYS-IP-5S"     =>	"142sys10",
    "SYS-IP-6"       =>	"142sys7",
    "SYS-IP-6S"     =>	"142sys9",

    "E3-SSD-1"	   =>    "143sys13",
    "E3-SSD-2"	   =>    "143sys10",
    "E3-SSD-3"	   =>    "143sys11",
    "E3-SSD-4"	   =>	 "143sys12",

    "E3-SAT-1"       =>    "143sys4",
    "E3-SAT-2"       =>    "143sys1",
    "E3-SAT-3"       =>    "143sys2",
    "E3-SAT-4"       =>	 "143sys3",

    "BK-8T"            =>    "141bk1",
    "BK-24T"	        =>    "141bk2",

     "GAME-1"    	   =>   "150game1",
     "GAME-2"		   =>    "150game2"
}

puts 'Specify the server model (ex. KS-1, KS-2 SSD,  etc):'
STDOUT.flush
$svm = nil
until  $svmodels.has_key?($svm)
    $svm = gets.chomp.upcase
    unless $svmodels.has_key?($svm)
        puts 'Please enter a valid server model:'
    end
end

puts 'Enter quantity [1-5]:'
STDOUT.flush
$svq = nil
until $svq.is_a?(Fixnum) && $svq.between?(1, 5)
  $svq = Integer(gets.chomp) rescue nil
  unless $svq.is_a?(Fixnum) && $svq.between?(1, 5)
     puts 'Please enter an integer between 1 and 5:'
  end
end

puts 'Enter your your KS account email:'
STDOUT.flush
$ovhemail = gets.chomp

puts 'Enter your your KS account password:'
STDOUT.flush
$ovhpass = STDIN.noecho(&:gets).chomp

system "clear"
puts 'Opening browser and checking availability...'

class Order
  include Capybara::DSL

  def crawl_and_order
    if /KS/.match($svm)
      opage = "https://kimsufi.com/fr/commande/kimsufi.xml?reference=#{$svmodels[$svm]}&quantity=#{$svq}"
    else
      opage = "https://eu.soyoustart.com/fr/commande/soYouStart.xml?reference=#{$svmodels[$svm]}&quantity=#{$svq}"
    end

    avail =
    until avail
      begin
        visit opage
        sleep(2)
        avail = page.has_text?('Récapitulatif de votre commande')
        time = Time.new.strftime("%H:%M:%S")
        if avail
          page.execute_script("document.getElementById('customerType-existing').click()")
          page.fill_in 'Email', :with => "#{$ovhemail}"
          page.fill_in 'Mot de passe', :with => "#{$ovhpass}"
          page.click_button('S\'identifier')

          page.check('contracts-validation')
          page.check('customConractAccepted')

          page.click_button('Confirmer et payer ma commande')
          sleep(5)

          page.save_screenshot("oproof.png")
          puts "[#{time}] Your #{$svm} server has been successfully acquired."
          exit(-1)
        end
      rescue Capybara::Poltergeist::TimeoutError
        retry
      rescue Capybara::Poltergeist::StatusFailError
	retry
      else
        puts "[#{time}] Server is not available yet."
      end
    end
  end
end

Order.new.crawl_and_order
