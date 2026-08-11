import axiosInstance from "./axiosInstance";

export const getInventory = async () => {
  const response = await axiosInstance.get("/inventory");
  return response.data;
};
