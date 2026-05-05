package com.assessment.www.Servlet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;

public class VideoStreamServlet extends HttpServlet {
    private static final int BUFFER_SIZE = 65536; // 64KB

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.isEmpty()) {
            response.sendError(404);
            return;
        }

        String realPath = getServletContext().getRealPath("/static/videos" + pathInfo);
        if (realPath == null) {
            response.sendError(404);
            return;
        }

        File videoFile = new File(realPath);
        if (!videoFile.exists() || !videoFile.isFile()) {
            response.sendError(404);
            return;
        }

        long fileLength = videoFile.length();
        String fileName = videoFile.getName();
        String mimeType = getServletContext().getMimeType(fileName);
        if (mimeType == null || !mimeType.startsWith("video/")) {
            mimeType = "video/mp4";
        }

        response.setContentType(mimeType);
        response.setHeader("Accept-Ranges", "bytes");
        response.setHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");

        String rangeHeader = request.getHeader("Range");
        if (rangeHeader == null) {
            response.setContentLength((int) fileLength);
            OutputStream out = response.getOutputStream();
            try (InputStream in = new BufferedInputStream(new FileInputStream(videoFile), BUFFER_SIZE)) {
                byte[] buffer = new byte[BUFFER_SIZE];
                int bytesRead;
                while ((bytesRead = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                    out.flush();
                }
            }
            return;
        }

        // Handle HTTP Range request
        long start = 0;
        long end = fileLength - 1;
        if (rangeHeader.startsWith("bytes=")) {
            String rangeValue = rangeHeader.substring("bytes=".length());
            int dashIndex = rangeValue.indexOf('-');
            try {
                if (dashIndex > 0) {
                    start = Long.parseLong(rangeValue.substring(0, dashIndex));
                }
                if (dashIndex < rangeValue.length() - 1) {
                    end = Long.parseLong(rangeValue.substring(dashIndex + 1));
                }
            } catch (NumberFormatException e) {
                start = 0;
            }
        }

        if (start >= fileLength) {
            response.setStatus(HttpServletResponse.SC_REQUESTED_RANGE_NOT_SATISFIABLE);
            response.setHeader("Content-Range", "bytes */" + fileLength);
            return;
        }

        if (end >= fileLength) {
            end = fileLength - 1;
        }

        long contentLength = end - start + 1;
        response.setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
        response.setContentLength((int) contentLength);
        response.setHeader("Content-Range", "bytes " + start + "-" + end + "/" + fileLength);

        try (RandomAccessFile raf = new RandomAccessFile(videoFile, "r")) {
            raf.seek(start);
            OutputStream out = response.getOutputStream();
            byte[] buffer = new byte[BUFFER_SIZE];
            long remaining = contentLength;
            while (remaining > 0) {
                int bytesToRead = (int) Math.min(remaining, BUFFER_SIZE);
                int bytesRead = raf.read(buffer, 0, bytesToRead);
                if (bytesRead == -1) break;
                out.write(buffer, 0, bytesRead);
                remaining -= bytesRead;
            }
            out.flush();
        }
    }
}
