class CommentsController < ApplicationController
	before_action :find_commentable

	def new
		@comment = Comment.new
	end

	def create
		@comment = @commentable.comments.new comment_params
		@comment.user_id = current_user.id

		if @comment.save
			if (@comment.commentable_type == "Post")
				create_notification @comment.commentable, @comment
				flash[:success] = "Your comment was successfully added!"
				redirect_to :back
			elsif (@comment.commentable_type == "Comment")
				flash[:success] = "Your Reply was successfully added!"
				redirect_to :back
			end
		else
			if (@comment.commentable_type == "Post")
				flash[:danger] = "Your comment wasn't added!"
			elsif (@comment.commentable_type == "Comment")
				flash[:danger] = "Your reply wasn't added!"
			end
			redirect_to :back
		end
	end

	def create_notification(post, comment)
		return if post.user.id == current_user.id
		Notification.create(user_id: post.user.id,
			notified_by_id: current_user.id,
			post_id: post.id,
			identifier: comment.id,
			notice_type: 'comment')
	end

	def destroy
		@comment = @commentable.comments.find(params[:id])
		@comment.destroy
		respond_to do |format|
			format.js
		end
	end  

	private

	def comment_params
		params.require(:comment).permit(:body)
	end

	def find_commentable
		@commentable = Comment.find_by_id(params[:comment_id]) if params[:comment_id]
		@commentable = Post.find_by_id(params[:post_id]) if params[:post_id]
	end
end

