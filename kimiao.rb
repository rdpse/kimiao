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
Capybara.app_host = 'http://kimsufi.com/fr'
Capybara.default_wait_time = 10

$svmodels = { 
	"KS-1"           =>   "150sk10",
	"KS-2"           =>   "150sk20",
	"KS-2 SSD"       =>   "150sk22",
	"KS-3"           =>   "150sk30",
	"KS-4"           =>   "150sk40",
	"KS-5"           =>   "150sk50",
	"KS-6"           =>   "150sk60",
}

puts 'Specify the server model (ex. KS-1, KS-2 SSD, etc):'
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

#def choices (var, methods*)
#    if methods > 1
#       until var.method[1] && var.method[2]
#

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
    kspage = "/commande/kimsufi.xml?reference=#{$svmodels[$svm]}&quantity=#{$svq}"
    syspage =
    avail =

    until avail
      begin
        visit kspage
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

          page.save_screenshot(oproof.png)
          puts "[#{time}] Your #{$svm} server has been successfully acquired."
          exit(-1)
        end
      rescue Capybara::Poltergeist::TimeoutError
        retry
      rescue Capybara::Poltergeist::StatusFailError
	retry
      else
        puts "[#{time}] Server is not available yet."
        page.execute_script "window.close()"
      end
    end
  end
end

Order.new.crawl_and_order

