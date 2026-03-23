function T = readFluentOut(filename)
%READFLUENTOUT 读取 Fluent 输出的 .out 文件为 table
%
%   T = readFluentOut(filename)
%
%   输入：
%       filename - .out 文件完整路径
%
%   输出：
%       T - table，表头自动提取括号内字段，如 x/d=-1
%

    fid = fopen(filename);
    if fid == -1
        error('无法打开文件：%s', filename);
    end

    % 跳过前两行
    fgetl(fid);
    fgetl(fid);

    % 第三行是含引号的表头
    headerLine = fgetl(fid);

    % 提取引号内的列名
    rawNames = regexp(headerLine, '"(.*?)"', 'tokens');
    rawNames = [rawNames{:}];  % 展平 cell

    % 提取括号内字段为变量名，否则使用原始名
    varNames = cell(size(rawNames));
    for i = 1:numel(rawNames)
        tokens = regexp(rawNames{i}, '\((.*?)\)', 'tokens');
        if ~isempty(tokens)
            varNames{i} = tokens{1}{1};  % 例如 x/d=-1
        else
            varNames{i} = rawNames{i};  % 例如 Time Step
        end
    end

    % 读取数值数据
    data = textscan(fid, repmat('%f', 1, numel(varNames)));
    fclose(fid);

    % 生成表格
    T = table();
    for i = 1:numel(varNames)
        T.(varNames{i}) = data{i};
    end

    fprintf('✅ 成功读取out文件!!：%s\n', filename);
end
