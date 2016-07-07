require 'test_helper'

class FubasControllerTest < ActionController::TestCase
  setup do
    @fuba = fubas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fubas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fuba" do
    assert_difference('Fuba.count') do
      post :create, :fuba => {  }
    end

    assert_redirected_to fuba_path(assigns(:fuba))
  end

  test "should show fuba" do
    get :show, :id => @fuba
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @fuba
    assert_response :success
  end

  test "should update fuba" do
    put :update, :id => @fuba, :fuba => {  }
    assert_redirected_to fuba_path(assigns(:fuba))
  end

  test "should destroy fuba" do
    assert_difference('Fuba.count', -1) do
      delete :destroy, :id => @fuba
    end

    assert_redirected_to fubas_path
  end
end
