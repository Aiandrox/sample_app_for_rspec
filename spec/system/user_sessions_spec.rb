require 'rails_helper'
require 'support/login_helpers'

RSpec.describe "UserSessions", type: :system do
  let!(:user) { create(:user) }
  let!(:task) { create(:task) }
  describe 'ログイン前' do
    before do
      visit login_path
      task = create(:task)
    end
    context 'フォームの入力値が正常' do
      before do
        fill_in 'Email', with: 'email@example.com'
        fill_in 'Password', with: 'password'
        click_button 'Login'
      end
      it('ログイン成功メッセージを表示'){ expect(page).to have_content 'Login successful' }
      it('ルートに遷移'){ expect(current_path).to eq root_path }
    end
    context 'メールアドレスが未入力' do
      before do
        fill_in 'Email', with: ''
        fill_in 'Password', with: 'password'
        click_button 'Login'
      end
      it('ログイン失敗メッセージを表示'){ expect(page).to have_content 'Login failed' }
      it('ログイン画面のまま'){ expect(current_path).to eq login_path }
    end
    context 'パスワードが不適' do
      before do
        fill_in 'Email', with: 'email@example.com'
        fill_in 'Password', with: 'not_password'
        click_button 'Login'
      end
      it('ログイン失敗'){ expect(page).to have_content 'Login failed' }
      it('ログイン画面のまま'){ expect(current_path).to eq login_path }
    end
    context 'ユーザー限定機能' do
      it 'タスク新規作成ページにアクセスできない' do
        visit new_task_path
        expect(current_path).to eq login_path
      end
      it 'タスク編集ページにアクセスできないこと' do
        visit edit_task_path(task)
        expect(current_path).to eq login_path
      end
      it 'マイページにアクセスできないこと' do
        visit user_path(user)
        expect(current_path).to eq login_path
      end
    end
  end

  describe 'ログイン後' do
    context 'ユーザー限定機能' do

    end
    context 'ログアウトボタンを押す' do
      before do
        login(user)
        click_link 'Logout'
      end
      it 'ログアウト成功' do
        expect(page).to have_content 'Logged out'
        expect(current_path).to eq root_path
      end
    end
  end
end
