require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { create(:user) }
  before { login(user) }
  describe 'タスクを新規作成するとき' do
    before do
      visit root_path
      click_link 'New Task'
    end
    context 'フォームの入力値が正常' do
      before do
        fill_in 'Title',	with: "New task's title"
        fill_in 'Content', with: "New task's content"
        select 'todo', from: 'Status'
        click_button 'Create Task'
      end
      it('新規タスクが作成される') { expect(page).to have_content  "New task's title" }
      it('新規タスク作成成功メッセージを表示') { expect(page).to have_content 'Task was successfully created.' }
      it('作成したタスクの詳細ページに遷移') { expect(current_path).to eq task_path(Task.last) }
    end
    context 'タイトルが未入力' do
      before do
        fill_in 'Title',	with: ''
        fill_in 'Content', with: "No title task's content"
        select 'todo', from: 'Status'
        click_button 'Create Task'
      end
      it('エラーメッセージを表示') { expect(page).to have_selector '#error_explanation', text: '1 error prohibited this task from being saved' }
      it('タスク新規作成ページのまま') { expect(current_path).to eq '/tasks' }
      it '入力内容が残っている' do
        expect(page).to have_field 'Title', with: ''
        expect(page).to have_field 'Content', with: "No title task's content"
        expect(page).to have_select 'Status', selected: 'todo'
      end
    end
  end

  describe 'タスク編集' do
    let!(:my_task) { create(:task, user_id: user.id) }
    let(:other_user) { create(:user) }
    let!(:other_users_task) { create(:task, user_id: other_user.id) }
    context '他人のタスク編集ページにアクセスするとき' do
      before { visit edit_task_path(other_users_task) }
      it('アクセス制限メッセージを表示') { expect(page).to have_content 'Forbidden access.' }
      it('ルートにリダイレクト') { expect(current_path).to eq root_path }
    end
    describe '自分のタスクの編集' do
      before do
        visit root_path
        click_link 'Edit', href: edit_task_path(my_task)
      end
      context 'フォームの入力値が正常なとき' do
        before do
          fill_in 'Title',	with: "Updated task's title"
          fill_in 'Content', with: "Updated task's content"
          select 'doing', from: 'Status'
          click_button 'Update Task'
        end
        it('更新後のタイトルを表示') { expect(page).to have_content "Updated task's title" }
        it('タスク詳細ページに遷移') { expect(current_path).to eq task_path(my_task) }
        it('タスク更新成功メッセージを表示') { expect(page).to have_content 'Task was successfully updated.' }
      end
      context 'タイトルが入力されていないとき' do
        before do
          fill_in 'Title', with: ''
          fill_in 'Content', with: "Updated task's content"
          select 'doing', from: 'Status'
          click_button 'Update Task'
        end
        it 'エラーメッセージを表示' do
          expect(page).to have_selector '#error_explanation', text: '1 error prohibited this task from being saved'
          expect(page).to have_selector '#error_explanation', text: "Title can't be blank"
        end
        it('タスク編集画面のまま') { expect(current_path).to eq task_path(my_task) }
        it '入力したデータが残っている' do
          expect(page).to have_field 'Content', with: "Updated task's content"
          expect(page).to have_select 'Status', selected: 'doing'
        end
      end
    end
  end

  xdescribe 'タスク削除' do
    let(:my_task) { create(:task, user_id: user.id) }
    let(:other_user) { create(:user) }
    let(:other_users_task) { create(:task, user_id: other_user.id) }
    context '他人のタスクを削除するとき' do
      before { page.driver.link :delete, task_path(other_users_task), {} }
      it('アクセス制限メッセージを表示') { expect(page).to have_content 'Forbidden access.' }
      it('ルートにリダイレクト') { expect(current_path).to eq root_path }
    end
    context '自分のタスクを削除するとき' do
      before do
        visit root_path
      end
    end
  end

  describe 'タスクの表示' do
    # マイページにタスクを表示
    # 自分以外のタスクには編集削除ボタンが非表示
  end
end
