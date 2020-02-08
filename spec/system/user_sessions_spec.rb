require 'rails_helper'

RSpec.describe "UserSessions", type: :system do
  let(:user) { create(:user) }
  describe 'ログイン' do
    before { visit login_path }
    it 'フォームの入力値が正常なとき 成功' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'password'
      click_button 'Login'
      expect(page).to have_content 'Login successful'
      expect(current_path).to eq root_path
    end
    it 'メールアドレスが未入力のとき 失敗' do
      fill_in 'Email', with: ''
      fill_in 'Password', with: 'password'
      click_button 'Login'
      expect(page).to have_content 'Login failed'
      expect(current_path).to eq login_path
    end
    it 'パスワードが不適なとき 失敗' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'not_password'
      click_button 'Login'
      expect(page).to have_content 'Login failed'
      expect(current_path).to eq login_path
    end
  end

  describe 'ログアウト' do
    it 'ログアウトボタンを押すとき 成功' do
      login(user)
      click_link 'Logout'
      expect(page).to have_content 'Logged out'
      expect(current_path).to eq root_path
    end
  end

  describe 'アクセス制限' do
    let!(:task) { create(:task) }
    shared_examples_for 'ログインページにリダイレクト' do
      it { expect(current_path).to eq login_path }
      it { expect(page).to have_content 'Login required' }
    end
    context '未ログインユーザーのとき' do
      context 'タスク新規作成ページにアクセスする' do
        before { visit new_task_path } 
        it_behaves_like 'ログインページにリダイレクト'
      end
      context 'タスク編集ページにアクセスするとき' do
        before { visit edit_task_path(task) }
        it_behaves_like 'ログインページにリダイレクト'
      end
      context 'マイページにアクセスするとき' do
        before { visit user_path(user) }
        it_behaves_like 'ログインページにリダイレクト'
      end
    end
    describe 'ログインユーザーのとき' do
      before { login(user) }
      it 'タスク新規作成ページにアクセスする 正しく遷移' do
        visit new_task_path
        expect(current_path).to eq new_task_path
      end
      it 'マイページにアクセスする 正しく遷移' do
        visit user_path(user)
        expect(current_path).to eq user_path(user)
      end
    end
  end
end
