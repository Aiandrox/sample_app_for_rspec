require 'rails_helper'

RSpec.describe "UserSessions", type: :system do
  let(:user) { create(:user) }
  describe 'ログイン' do
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

  describe 'ログアウト' do
    before { login(user) }
    context 'ログアウトボタンを押す' do
      before do
        click_link 'Logout'
      end
      it('ログアウト成功メッセージを表示') { expect(page).to have_content 'Logged out' }
      it('ルートに遷移') { expect(current_path).to eq root_path }
    end
  end

  describe 'アクセス制限に関して' do
    let!(:task) { create(:task) }
    shared_examples_for 'ログインページにリダイレクト' do
      it { expect(current_path).to eq login_path }
    end
    shared_examples_for 'ログイン要求メッセージを表示' do
      it { expect(page).to have_content 'Login required' }
    end
    describe '未ログインユーザーが' do
      context 'タスク新規作成ページにアクセスするとき' do
        before { visit new_task_path } 
        it_behaves_like 'ログイン要求メッセージを表示'
        it_behaves_like 'ログインページにリダイレクト'
      end
      context 'タスク編集ページにアクセスするとき' do
        before { visit edit_task_path(task) }
        it_behaves_like 'ログイン要求メッセージを表示'
        it_behaves_like 'ログインページにリダイレクト'
      end
      context 'マイページにアクセスするとき' do
        before { visit user_path(user) }
        it_behaves_like 'ログイン要求メッセージを表示'
        it_behaves_like 'ログインページにリダイレクト'
      end
    end
    describe 'ログインユーザーが' do
      before { login(user) }
      context 'タスク新規作成ページにアクセスするとき' do
        before { visit new_task_path }
        it('正しく遷移') { expect(current_path).to eq new_task_path }
      end
      context 'マイページにアクセスするとき' do
        before { visit user_path(user) }
        it('正しく遷移') { expect(current_path).to eq user_path(user) }
      end
    end
  end
end
