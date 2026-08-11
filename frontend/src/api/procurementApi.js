import axiosInstance from "./axiosInstance";

export const getProcurement = async () => {
  const response = await axiosInstance.get("/procurement");
  return response.data;
};
