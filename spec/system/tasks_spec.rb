require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { create(:user) }
  let!(:my_task) { create(:task, user: user) }
  let(:other_user) { create(:user) }
  let!(:other_user_task) { create(:task, user: other_user) }

  describe 'タスク新規作成' do
    it 'ログインしていないとき ログインページにリダイレクト' do
      visit new_task_path
      expect(current_path).to eq login_path
      expect(page).to have_content 'Login required'
    end
    context 'ログインしているとき' do
      before do
        login(user)
        visit root_path
        click_link 'New Task'
        expect(current_path).to eq new_task_path
      end
      it 'フォームの入力値が正常なとき 成功' do
        fill_in 'Title',	with: "New task's title"
        fill_in 'Content', with: "New task's content"
        select 'todo', from: 'Status'
        click_button 'Create Task'
        expect(page).to have_content 'Task was successfully created.'
        expect(page).to have_content "Title: New task's title"
        expect(page).to have_content "Content: New task's content"
      end
      it 'タイトルが未入力のとき 失敗' do
        fill_in 'Title',	with: ''
        fill_in 'Content', with: "No title task's content"
        select 'todo', from: 'Status'
        click_button 'Create Task'
        expect(page).to have_selector '#error_explanation', text: '1 error prohibited this task from being saved'
        expect(current_path).to eq '/tasks'
        expect(page).to have_field 'Title', with: ''
        expect(page).to have_field 'Content', with: "No title task's content"
        expect(page).to have_select 'Status', selected: 'todo'
      end
    end
  end

  describe 'タスク編集' do
    it 'ログインしていないとき ログインページにリダイレクト' do
      visit edit_task_path(my_task)
      expect(current_path).to eq login_path
      expect(page).to have_content 'Login required'
    end
    it '他人のタスク編集ページにアクセスするとき アクセスを弾かれる' do
      login(user)
      visit edit_task_path(other_user_task)
      expect(page).to have_content 'Forbidden access.'
      expect(current_path).to eq root_path
    end
    describe '自分のタスクの編集' do
      before do
        login(user)
        visit root_path
        click_link 'Edit', href: edit_task_path(my_task)
        expect(current_path).to eq edit_task_path(my_task)
      end
      it 'フォームの入力値が正常なとき 成功' do
        fill_in 'Title',	with: "Updated task's title"
        fill_in 'Content', with: "Updated task's content"
        select 'doing', from: 'Status'
        click_button 'Update Task'
        expect(page).to have_content "Updated task's title"
        expect(current_path).to eq task_path(my_task)
        expect(page).to have_content 'Task was successfully updated.'
      end
      it 'タイトルが入力されていないとき 失敗' do
        fill_in 'Title', with: ''
        fill_in 'Content', with: "Updated task's content"
        select 'doing', from: 'Status'
        click_button 'Update Task'
        expect(page).to have_selector '#error_explanation', text: '1 error prohibited this task from being saved'
        expect(page).to have_selector '#error_explanation', text: "Title can't be blank"
        expect(current_path).to eq task_path(my_task)
        expect(page).to have_field 'Content', with: "Updated task's content"
        expect(page).to have_select 'Status', selected: 'doing'
      end
    end
  end

  describe 'タスク削除' do
    before do
      login(user)
      visit root_path
      click_link 'Destroy', href: task_path(my_task)
      expect(page.driver.browser.switch_to.alert.text).to eq 'Are you sure?'
    end
    it 'タスクの削除を許可するとき 削除される' do
      page.accept_confirm
      expect(page).to have_content 'Task was successfully destroyed.'
      expect(current_path).to eq tasks_path
      expect(page).to have_no_content my_task.title
    end
    it 'タスクの削除をキャンセルするとき 削除されない' do
      page.dismiss_confirm
      expect(current_path).to eq root_path
      expect(page).to have_content my_task.title
    end
  end

  describe 'タスクの表示' do
    before { login(user) }
    it 'マイページに自分のタスクのみ表示' do
      visit user_path(user)
      expect(page).to have_content user.tasks.count
      expect(page).to have_content my_task.title
      expect(page).to have_no_content other_user_task.title
    end
    context 'タスク一覧画面に' do
      before { visit tasks_path }
      it '全てのタスクにShowボタンを表示' do
        expect(page).to have_link 'Show', href: task_path(my_task)
        expect(page).to have_link 'Show', href: task_path(other_user_task)
      end
      it '自分のタスクにEdit/Destroyボタンを表示' do
        expect(page).to have_link 'Edit', href: edit_task_path(my_task)
        expect(page).to have_link 'Destroy', href: task_path(my_task)
      end
      it '他人のタスクにはEdit/Destroyボタンが非表示' do
        expect(page).to have_no_link 'Edit', href: edit_task_path(other_user_task)
        expect(page).to have_no_link 'Destroy', href: task_path(other_user_task)
      end
    end
  end
end
