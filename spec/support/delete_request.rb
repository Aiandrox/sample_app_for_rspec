module DeleteRequestHelpers
  def send_delete_request(path)
    current_driver = Capybara.current_driver
    Capybara.current_driver = :rack_test
    page.driver.delete path
    Capybara.current_driver = current_driver
  end
end
