function [obsData, obsMap] = observe_pose(map, pose, visibleRate, noiseStd)
%OBSERVE_POSE  Measure relative pose from the given pose to landmarks.
%
%   [OBS_DATA, OBS_MAP] = OBSERVE_POSE(MAP, POSE, VISIBLE_RATE, NOISE_STD)
%       (matrix) MAP         : A landmark map (Nx6 matrix)
%       (matrix) POSE        : Pose of the target object (1x6 matrix)
%       (scalar) VISIBLE_RATE: Visible probability of landmarks (default: 1)
%       (matrix) NOISE_STD   : Standard deviation of measurement (1x2 matrix, default: [0, 0])
%       (matrix) OBS_DATA    : The measured relative pose from POSE to landmarks (Mx6 matrix)
%       (matrix) OBS_MAP     : The landmark map of measured landmarks (Mx6 matrix)
%
%   Note: Pose of an object, POSE, is represented by 1x6 vector whose first three
%       columns represent position of the object, (x, y, z), and last three
%       columns represent orientation of the object, (r_x, r_y, r_z) [rad].
%
%   Note: A landmark map, MAP, is Nx6 matrix which contains position and
%       orientation of landmarks in the world coordinate. Its first three columns
%       represents position of landmarks, (x, y, z). Its last three columns represent
%       orientation of landmarks, (r_x, r_y, r_z) [rad].
%
%   Note: The number of output data, M, will be approximately VISIBLE_RATE * N.
%       If there is no visible landmark, OBS_DATA and OBS_MAP will be empty matrice.
%       Please use the command, ISEMPTY, to identify an empty matrix.
%
%   Note: The measured relative pose, OBS_DATA, is represented by Mx6 matrix whose
%       format is exactly same with POSE and MAP.
%
%   Note: Standard deviation, NOISE_STD, is 1x2 matrix whose first element affects to
%       translational parts (1:3) and second element affects to rotational parts (4:6).
%
%   Examples:
%       map  = [ 0, 0, 5, 0, 0, 0; ...
%                5, 0, 5, 0, 0, 0; ...
%                5, 5, 5, 0, 0, 0 ];
%                0, 5, 5, 0, 0, 0 ];
%       pose = [ 3, 2, 9, 0, 0, pi / 2 ];
%       [obsData, obsMap] = observe_displacement(map, pose)
%
%   See also observe_distance, observe_bearing, observe_displacement.

if nargin < 3
    visibleRate = 1;
end
if nargin < 4
    noiseStd = 0;
end
if length(noiseStd) < 2
    noiseStd = [noiseStd, noiseStd];
end

isVisible = rand(size(map,1), 1) < visibleRate; % Select visible landmarks
obsMap = map(isVisible,:);
obsNum = size(obsMap,1);
obsDim = 6;

obsData = zeros(obsNum,obsDim);
if obsNum > 0
    delta = obsMap(:,1:3) - repmat(pose(1:3), obsNum, 1);
    obsData(:,1:3) = delta * tran_rad2rot(pose(4:6)); % Calculate displacement
                                                      % a = R' * b --> a' = b' * R
    for i = 1:obsNum
        R = tran_rad2rot(pose(4:6))' * tran_rad2rot(obsMap(i,4:6)); % Calculate orientation one by one
        obsData(i,4:6) = tran_rot2rad(R);
    end
    obsData(:,1:3) = obsData(:,1:3) + noiseStd(1) * randn(obsNum,obsDim/2); % Add Gaussian noise
    obsData(:,4:6) = obsData(:,4:6) + noiseStd(2) * randn(obsNum,obsDim/2); % Add Gaussian noise
end
