require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe 'ユーザー新規作成' do
    before { visit new_user_path }
    context 'フォームの入力値が正常なとき' do
      before do
        fill_in 'Email', with: 'email@example.com'
        fill_in 'Password', with: 'password'
        fill_in 'Password confirmation', with: 'password'
        click_button 'SignUp'
      end
      it('ユーザー作成成功メッセージを表示') { expect(page).to have_content 'User was successfully created.' }
      it('ログインページに遷移') { expect(current_path).to eq login_path }
    end
    context 'メールアドレスが未入力のとき' do
      before do
        fill_in 'Email', with: ''
        fill_in 'Password', with: 'password'
        fill_in 'Password confirmation', with: 'password'
        click_button 'SignUp'
      end
      it 'エラーメッセージを表示' do
        expect(page).to have_selector '#error_explanation', text: '1 error prohibited this user from being saved'
        expect(page).to have_selector '#error_explanation', text: "Email can't be blank"
      end
      it('ユーザー作成画面のまま') { expect(current_path).to eq '/users' }
    end
    context 'メールアドレスが重複するとき' do
      let(:existed_user) { create(:user) }
      before do
        fill_in 'Email', with: existed_user.email
        fill_in 'Password', with: 'password'
        fill_in 'Password confirmation', with: 'password'
        click_button 'SignUp'
      end
      it 'エラーメッセージを表示' do
        expect(page).to have_selector '#error_explanation', text: '1 error prohibited this user from being saved'
        expect(page).to have_selector '#error_explanation', text: 'Email has already been taken'
      end
      it('ユーザー作成画面のまま') { expect(current_path).to eq '/users' }
      it('入力したメールアドレスが残っている') { expect(page).to have_field 'Email', with: existed_user.email }
    end
  end

  describe 'ユーザー編集' do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    before { login(user) }
    context '他ユーザーの編集ページにアクセスするとき' do
      before do
        visit edit_user_path(other_user)
      end
      it('アクセス制限メッセージを表示') { expect(page).to have_content 'Forbidden access.' }
      it('自分の詳細ページにリダイレクト') { expect(current_path).to eq user_path(user) }
    end
    describe '自分ユーザー情報の編集' do
      before do
        visit root_path
        click_on 'Mypage'
        click_on 'Edit'
      end
      context 'フォームの入力値が正常なとき' do
        before do
          fill_in 'Email', with: 'new_email@example.com'
          click_button 'Update'
        end
        it('ユーザー更新成功メッセージを表示') { expect(page).to have_content 'User was successfully updated.' }
        it('ユーザー詳細ページに遷移') { expect(current_path).to eq user_path(user) }
        it('更新後のメールアドレスを表示') { expect(page).to have_content 'new_email@example.com' }
      end
      context 'メールアドレスが入力されていないとき' do
        before do
          fill_in 'Email', with: ''
          click_button 'Update'
        end
        it 'エラーメッセージを表示' do
          expect(page).to have_selector '#error_explanation', text: '1 error prohibited this user from being saved'
          expect(page).to have_selector '#error_explanation', text: "Email can't be blank"
        end
        it('ユーザー編集画面のまま') { expect(current_path).to eq user_path(user) }
        it('入力したメールアドレスが残っている') { expect(page).to have_field 'Email', with: '' }
      end
      context 'メールアドレスが重複しているとき' do
        before do
          fill_in 'Email', with: other_user.email
          click_button 'Update'
        end
        it 'エラーメッセージを表示' do
          expect(page).to have_selector '#error_explanation', text: '1 error prohibited this user from being saved'
          expect(page).to have_selector '#error_explanation', text: "Email has already been taken"
        end
        it('ユーザー編集画面のまま') { expect(current_path).to eq user_path(user) }
        it('入力したメールアドレスが残っている') { expect(page).to have_field 'Email', with: other_user.email }
      end
    end
  end
end
