module LoginHelpers
  def login(user)
    visit root_path
    click_link 'Login'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password'
    click_button 'Login'
    expect(page).to have_content 'Login successful'
  end
end
