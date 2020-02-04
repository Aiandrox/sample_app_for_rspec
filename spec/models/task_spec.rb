require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validation' do
    let(:new_task) { build(:task, title: title, status: status) }
    let(:title) { 'タイトル' }
    let(:status) { :todo }

    context '全て入力されている場合' do
      let(:task) { create(:task) }
      it '有効' do
        expect(task).to be_valid
      end
    end

    context 'タイトルが入力されていない場合' do
      let(:title) { '' }
      it '無効' do
        expect(new_task).to be_invalid
      end
    end

    context 'タイトルが重複する場合' do
      let!(:task) { create(:task) }
      let(:task_with_duplicated_title) { new_task }
      it '無効' do
        expect(task_with_duplicated_title).to be_invalid
      end
    end

    context 'タイトルが重複しない場合' do
      let!(:task) { create(:task) }
      let(:title) { '違うタイトル' }
      it '有効' do
        expect(new_task).to be_valid
      end
    end

    context 'ステータスが空白の場合' do
      let(:status) { '' }
      it '無効' do
        expect(new_task).to be_invalid
      end
    end

    context '設定されていないステータスを入力した場合' do
      subject { -> { let(:status) { :not_set } } }
      it '例外を返す' do
        expect(subject).to raise_error(StandardError)
      end
    end
  end
end
