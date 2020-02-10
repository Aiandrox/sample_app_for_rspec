require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe 'ユーザー新規作成' do
    let(:existed_user) { create(:user) }
    before { visit new_user_path }
    it 'フォームの入力値が正常なとき 成功' do
      fill_in 'Email', with: 'email@example.com'
      fill_in 'Password', with: 'password'
      fill_in 'Password confirmation', with: 'password'
      click_button 'SignUp'
      expect(page).to have_content 'User was successfully created.'
      expect(current_path).to eq login_path
    end
    it 'メールアドレスが未入力のとき 失敗' do
      fill_in 'Email', with: ''
      fill_in 'Password', with: 'password'
      fill_in 'Password confirmation', with: 'password'
      click_button 'SignUp'
      expect(page).to have_selector '#error_explanation', text: '1 error prohibited this user from being saved'
      expect(page).to have_selector '#error_explanation', text: "Email can't be blank"
      expect(current_path).to eq '/users'
    end
    it 'メールアドレスが重複するとき 失敗' do
      fill_in 'Email', with: existed_user.email
      fill_in 'Password', with: 'password'
      fill_in 'Password confirmation', with: 'password'
      click_button 'SignUp'
      expect(page).to have_selector '#error_explanation', text: '1 error prohibited this user from being saved'
      expect(page).to have_selector '#error_explanation', text: 'Email has already been taken'
      expect(current_path).to eq '/users'
      expect(page).to have_field 'Email', with: existed_user.email
    end
  end

  describe 'ユーザー編集' do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    before { login(user) }
    it '他ユーザーの編集ページにアクセスするとき アクセスを弾かれる' do
      visit edit_user_path(other_user)
      expect(page).to have_content 'Forbidden access.'
      expect(current_path).to eq user_path(user)
    end
    context '自分のユーザー情報の場合' do
      before do
        visit root_path
        click_on 'Mypage'
        click_on 'Edit'
      end
      it 'フォームの入力値が正常なとき 成功' do
        fill_in 'Email', with: 'new_email@example.com'
        click_button 'Update'
        expect(page).to have_content 'User was successfully updated.'
        expect(current_path).to eq user_path(user)
        expect(page).to have_content 'new_email@example.com'
      end
      it 'メールアドレスが入力されていないとき 失敗' do
        fill_in 'Email', with: ''
        click_button 'Update'
        expect(page).to have_selector '#error_explanation', text: '1 error prohibited this user from being saved'
        expect(page).to have_selector '#error_explanation', text: "Email can't be blank"
        expect(current_path).to eq user_path(user)
        expect(page).to have_field 'Email', with: ''
      end
      it 'メールアドレスが重複しているとき 失敗' do
        fill_in 'Email', with: other_user.email
        click_button 'Update'
        expect(page).to have_selector '#error_explanation', text: '1 error prohibited this user from being saved'
        expect(page).to have_selector '#error_explanation', text: "Email has already been taken"
        expect(current_path).to eq user_path(user)
        expect(page).to have_field 'Email', with: other_user.email
      end
    end
  end
end
