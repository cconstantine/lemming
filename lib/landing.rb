#/usr/bin/env ruby

require './client'
client = Client.new('http://localhost:3000', $stdout)
client.visit('/')
sleep 1
client.visit("/how_it_works")
sleep 1
client.visit("/risk_assessment")

