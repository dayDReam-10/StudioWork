package com.assessment.www.Servlet;

import com.assessment.www.Service.VideoService;
import com.assessment.www.Service.VideoServiceImpl;
import com.assessment.www.po.User;
import com.assessment.www.po.Video;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

//首页Servlet
@WebServlet("/")
public class HomeServlet extends HttpServlet {
    private VideoService videoService = new VideoServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");
            List<Video> videos = videoService.searchVideos(user, "", 1, 20);
            request.setAttribute("videos", videos);
        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");
            List<Video> videos = videoService.searchVideos(user, "", 1, 20);
            request.setAttribute("videos", videos);
        }
        request.getRequestDispatcher("/WEB-INF/views/index.jsp").forward(request, response);
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}