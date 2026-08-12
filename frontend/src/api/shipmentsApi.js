import axiosInstance from "./axiosInstance";

export const getShipments = async () => {
  const response = await axiosInstance.get("/shipments");
  return response.data;
};
