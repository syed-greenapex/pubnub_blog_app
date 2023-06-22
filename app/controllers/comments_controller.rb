 class CommentsController < ApplicationController

	before_action :find_post, only: [:create, :destroy]

	def create
		@comment = @post.comments.build(comment_params)
		$pubnub.publish(
			channel: "channel-#{@post.id}",
			message: {
			  name: @comment.name,
			  comment: @comment.comment
			}
		  )

		respond_to do |format|
		  if @comment.save
			format.js { head :no_content } # Respond to AJAX request with no content
			format.html { redirect_to post_path(@post) }
		  else
			format.js { render :new } # Render the form again for AJAX request
			format.html { render :new }
		  end
		end
	end

	def destroy
		
		@comment = @post.comments.find(params[:id])
		@comment.destroy
		redirect_to post_path(@post)
	end

	private

	def comment_params
	  params.require(:comment).permit(:name, :comment)
	end

	def find_post
		@post = Post.find(params[:post_id])
	end
end
