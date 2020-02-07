require 'rails_helper'
require 'support/login_helpers'

RSpec.describe "UserSessions", type: :system do
  let(:user) { create(:user) }
  describe 'ログイン前' do
    before { visit login_path }
    context 'フォームの入力値が正常なとき' do
      before do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: 'password'
        click_button 'Login'
      end
      it('ログイン成功メッセージを表示') { expect(page).to have_content 'Login successful' }
      it('ルートに遷移') { expect(current_path).to eq root_path }
    end
    context 'メールアドレスが未入力のとき' do
      before do
        fill_in 'Email', with: ''
        fill_in 'Password', with: 'password'
        click_button 'Login'
      end
      it('ログイン失敗メッセージを表示') { expect(page).to have_content 'Login failed' }
      it('ログイン画面のまま') { expect(current_path).to eq login_path }
    end
    context 'パスワードが不適なとき' do
      before do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: 'not_password'
        click_button 'Login'
      end
      it('ログイン失敗メッセージを表示') { expect(page).to have_content 'Login failed' }
      it('ログイン画面のまま') { expect(current_path).to eq login_path }
    end
  end

  describe 'ログイン後' do
    before { login(user) }
    context 'ログアウトボタンを押す' do
      before do
        click_link 'Logout'
      end
      it('ログアウト成功メッセージを表示') { expect(page).to have_content 'Logged out' }
      it('ルートに遷移') { expect(current_path).to eq root_path }
    end
  end

  describe 'アクセス制限' do
    let!(:task) { create(:task) }
    describe '未ログインユーザー' do
      context 'タスク新規作成ページにアクセスするとき' do
        before { visit new_task_path } 
        it('ログイン要求メッセージを表示') { expect(page).to have_content 'Login required' }
        it('ログインページにリダイレクト') { expect(current_path).to eq login_path }
      end
      context 'タスク編集ページにアクセスするとき' do
        before { visit edit_task_path(task) }
        it('ログイン要求メッセージを表示') { expect(page).to have_content 'Login required' }
        it('ログインページにリダイレクト') { expect(current_path).to eq login_path }
      end
      context 'マイページにアクセスするとき' do
        before { visit user_path(user) }
        it('ログイン要求メッセージを表示') { expect(page).to have_content 'Login required' }
        it('ログインページにリダイレクト') { expect(current_path).to eq login_path }
      end
    end
    describe 'ログインユーザー' do
      before { login(user) }
      context 'タスク新規作成ページにアクセスするとき' do
        before { visit new_task_path }
        it('正しく遷移') { expect(current_path).to eq new_task_path }
      end
      xcontext 'タスク編集ページにアクセスするとき' do
        before { visit edit_task_path(task) }
        it('正しく遷移') { expect(current_path).to eq edit_task_path(task) }
      end
      context 'マイページにアクセスするとき' do
        before { visit user_path(user) }
        it('正しく遷移') { expect(current_path).to eq user_path(user) }
      end
    end
  end
end
