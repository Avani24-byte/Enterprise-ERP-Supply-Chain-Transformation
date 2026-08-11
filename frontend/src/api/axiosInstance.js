import axios from "axios";

const axiosInstance = axios.create({
  baseURL: "http://localhost:8081", // updated to match Avani's live endpoint
  headers: {
    "Content-Type": "application/json",
  },
});

export default axiosInstance;
