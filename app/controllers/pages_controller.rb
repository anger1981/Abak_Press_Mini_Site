class PagesController < ApplicationController  
  before_action :parser_url, only: [:show, :edit, :update, :destroy, :new] #находим id нужной нам страницы по url адресу
  before_action :build_pages_tree, only: [:first_root] #строим дерево адресов по которому находим нужную страницу и дерево меню


  def initialize
    @pages_tree = Hash.new()
    @pages_menu = Hash.new()
  end
  
  def build_pages_tree(str_args = "is NULL", str_path = '', flag_rec = false)
    Page.where(["parent_id " + str_args]).select(:id, :parent_id, :name) do |m|
        @pages_tree[m.id] = str_path + '/' + m.name.to_s
        @pages_menu[m.name.to_s] = str_path + '/' + m.name.to_s
        build_pages_tree('= ' + m.id.to_s, str_path + '/' + m.name, true) if Page.find_by_parent_id(m.id)
    end    
    if not(flag_rec)
      session[:pages_tree] = @pages_tree
      session[:pages_menu] = @pages_menu
    end
  end
  
  
  def first_root
    page_first_root_id = (Page.where(["parent_id is NULL"])).minimum(:id)
    @page = Page.find(page_first_root_id)
      if not @page.nil?
        redirect_to @pages_tree[@page.id]
      end
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
   render layout: 'layouts/application'
  end
  
  def new_root
    parent_id = nil
    new_id = Page.maximum(:id) + 1
    @page = Page.new(id: new_id, parent_id: parent_id)
    render layout: 'layouts/application'
  end

  # GET /pages/new
  def new
    parent_id = @page.id
    new_id = Page.maximum(:id) + 1
    @page = Page.new(id: new_id, parent_id: parent_id)
      render layout: 'layouts/application'
  end

  # GET /pages/1/edit
  def edit
      render layout: 'layouts/application'
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new(page_params)
    respond_to do |format|
      if @page.save
        self.build_pages_tree
        format.html { redirect_to @pages_tree[@page.id], notice: 'Page was successfully created.' }
        format.json { render :show, status: :created, location: @page }
      else
        format.html { render :new }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1
  # PATCH/PUT /pages/1.json
  def update
    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to @pages_tree[(@page.id).to_s], notice: 'Page was successfully updated.' }
        format.json { render :show, status: :ok, location: @page }
      else
        format.html { render :edit }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @page.destroy
    respond_to do |format|
      self.build_pages_tree
      self.first_root
    end
  end

  private
#    # Use callbacks to share common setup or constraints between actions.
#    def set_page
#      @page = Page.find(params[:id])
#    end
  def parser_url
    @pages_tree = session[:pages_tree]
    @pages_menu = session[:pages_menu]
    page_id = @pages_tree.index("/" + params[:url].to_s)
      if page_id.nil?
        respond_to do |format|
        format.html { redirect_to @pages_tree[((Page.where(["parent_id is NULL"])).minimum(:id)).to_s], notice: "Page #{params[:url].to_s} not exists." }
        end
      else
       @page = Page.find(page_id)
      end
  end
  

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
       param = params.require(:page).permit(:id, :parent_id, :name, :title, :body, :reference)
         param['body'].gsub!(/(\*\*(?<bold>([^(\*\*)]+))\*\*)/, '<b>\k<bold></b>')
         param['body'].gsub!(/(\\\\(?<italic>([^(\\\\)]+))\\\\)/, '<i>\k<italic></i>')
         param['body'].gsub!(/(\(\(\s*(?<ref>([^(\(\()(\)\))( )]+\/*))\s*(?<txt>([^(\(\()(\)\))]+))\s*\)\))/, '<a href="/\k<ref>">\k<txt></a>')
      return param
    end
    
end
