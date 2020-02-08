require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { create(:user) }
  let!(:my_task) { create(:task, user: user) }
  let(:other_user) { create(:user) }
  let!(:other_users_task) { create(:task, user: other_user) }
  before { login(user) }

  describe 'タスク新規作成' do
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
        it '入力内容が残っている' do
          expect(page).to have_field 'Content', with: "Updated task's content"
          expect(page).to have_select 'Status', selected: 'doing'
        end
      end
    end
  end

  describe 'タスク削除' do
    fcontext '他人のタスクを削除するとき' do
      before { send_delete_request(task_path(other_users_task)) }
      it('他人のタスクが削除されていない') { expect(page).to have_content other_users_task.title }
      it('ルートにリダイレクト') { expect(current_path).to eq root_path }
    end
    context '自分のタスクを削除するとき' do
      before do
        visit root_path
        click_link 'Destroy', href: task_path(my_task)
      end
      it('確認ダイアログを表示') { expect(page.driver.browser.switch_to.alert.text).to eq 'Are you sure?' }
      context 'タスクの削除を許可するとき' do
        before { page.accept_confirm }
        it('タスク削除成功メッセージを表示') {expect(page).to have_content 'Task was successfully destroyed.' }
        it('タスク一覧ページにリダイレクト') { expect(current_path).to eq tasks_path }
        it('タスク一覧ページからタイトルが削除'){ expect(page).to have_no_content my_task.title }
      end
      context 'タスクの削除をキャンセルするとき' do
        before { page.dismiss_confirm }
        it('ルートのまま') { expect(current_path).to eq root_path }
        it('タスク一覧ページにタイトルが存在する') { expect(page).to have_content my_task.title }
      end
    end
  end

  describe 'タスクの表示' do
    context 'タスク一覧画面' do
      before { visit tasks_path }
      it '全てのタスクにShowボタンを表示' do
        expect(page).to have_link 'Show', href: task_path(my_task)
        expect(page).to have_link 'Show', href: task_path(other_users_task)
      end
      it '自分のタスクにEdit/Destroyボタンを表示' do
        expect(page).to have_link 'Edit', href: edit_task_path(my_task)
        expect(page).to have_link 'Destroy', href: task_path(my_task)
      end
      it '他人のタスクにはEdit/Destroyボタンが非表示' do
        expect(page).to have_no_link 'Edit', href: edit_task_path(other_users_task)
        expect(page).to have_no_link 'Destroy', href: task_path(other_users_task)
      end
    end
    context 'マイページ' do
      before { visit user_path(user) }
      it('自分のタスクの数を表示') { expect(page).to have_content user.tasks.count }
      it('自分のタスクを表示') { expect(page).to have_content my_task.title }
      it('他人のタスクは非表示') { expect(page).to have_no_content other_users_task.title }
    end
  end
end
